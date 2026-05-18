const express = require('express');
const router = express.Router();
const bcrypt = require('bcryptjs');
const multer = require('multer');
const csv = require('csvtojson');
const fs = require('fs');
const path = require('path');
const User = require('../models/User');
const auth = require('../middleware/auth');

const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    const dir = path.join(__dirname, '../uploads');
    if (!fs.existsSync(dir)) fs.mkdirSync(dir);
    cb(null, dir);
  },
  filename: (req, file, cb) => cb(null, `${Date.now()}-${file.originalname}`),
});

const upload = multer({
  storage,
  fileFilter: (req, file, cb) => {
    if (file.mimetype === 'text/csv' || file.originalname.endsWith('.csv')) cb(null, true);
    else cb(new Error('Only CSV files allowed'));
  },
});

// GET /api/staff
router.get('/', auth, async (req, res) => {
  try {
    const staff = await User.find({ role: { $in: ['Teacher', 'HOD', 'Principal', 'Library'] } })
      .select('-password').sort({ createdAt: -1 });
    res.json(staff);
  } catch (err) { res.status(500).json({ message: err.message }); }
});

// POST /api/staff/add - manual add
router.post('/add', auth, async (req, res) => {
  try {
    const { name, email, phone, department, subject, designation, teacherId, password, role } = req.body;
    if (!name || !teacherId || !password || !role) {
      return res.status(400).json({ message: 'Name, Staff ID, Password and Role are required' });
    }
    const existing = await User.findOne({ teacherId: teacherId.trim() });
    if (existing) return res.status(400).json({ message: `Staff ID "${teacherId}" already exists` });

    const hashed = await bcrypt.hash(password.trim(), 10);
    const staff = await User.create({
      name: name.trim(), email: email?.trim().toLowerCase(), phone: phone?.trim(),
      department: department?.trim(), subject: subject?.trim(), designation: designation?.trim(),
      teacherId: teacherId.trim(), password: hashed, role, isFirstLogin: true, isActive: true,
    });

    res.status(201).json({ message: 'Staff added successfully', staff: { id: staff._id, name: staff.name, teacherId: staff.teacherId, role: staff.role } });
  } catch (err) { res.status(500).json({ message: err.message }); }
});

// POST /api/staff/upload-csv - bulk CSV add
// CSV: name, email, phone, department, subject, designation, teacherId, password, role
router.post('/upload-csv', auth, upload.single('file'), async (req, res) => {
  try {
    if (!req.file) return res.status(400).json({ message: 'No CSV file uploaded' });
    const rows = await csv().fromFile(req.file.path);
    const results = { success: 0, failed: 0, errors: [] };

    for (const row of rows) {
      try {
        if (!row.name || !row.teacherId || !row.password || !row.role) {
          results.failed++;
          results.errors.push(`Missing required fields: ${JSON.stringify(row)}`);
          continue;
        }
        const validRoles = ['Teacher', 'HOD', 'Principal', 'Library'];
        if (!validRoles.includes(row.role?.trim())) {
          results.failed++;
          results.errors.push(`Invalid role "${row.role}" for ${row.name}`);
          continue;
        }
        const existing = await User.findOne({ teacherId: row.teacherId.trim() });
        if (existing) {
          results.failed++;
          results.errors.push(`Staff ID "${row.teacherId}" already exists`);
          continue;
        }
        const hashed = await bcrypt.hash(row.password.trim(), 10);
        await User.create({
          name: row.name?.trim(), email: row.email?.trim().toLowerCase(), phone: row.phone?.trim(),
          department: row.department?.trim(), subject: row.subject?.trim(), designation: row.designation?.trim(),
          teacherId: row.teacherId?.trim(), password: hashed, role: row.role?.trim(),
          isFirstLogin: true, isActive: true,
        });
        results.success++;
      } catch (rowErr) {
        results.failed++;
        results.errors.push(rowErr.message);
      }
    }

    fs.unlinkSync(req.file.path);
    res.json({ message: `Upload complete. ${results.success} added, ${results.failed} failed.`, ...results });
  } catch (err) { res.status(500).json({ message: err.message }); }
});

// PUT /api/staff/:id
router.put('/:id', auth, async (req, res) => {
  try {
    const staff = await User.findByIdAndUpdate(req.params.id, req.body, { new: true }).select('-password');
    res.json(staff);
  } catch (err) { res.status(500).json({ message: err.message }); }
});

// DELETE /api/staff/:id
router.delete('/:id', auth, async (req, res) => {
  try {
    await User.findByIdAndDelete(req.params.id);
    res.json({ message: 'Staff deleted' });
  } catch (err) { res.status(500).json({ message: err.message }); }
});

// POST /api/staff/reset-password/:id
router.post('/reset-password/:id', auth, async (req, res) => {
  try {
    const { newPassword } = req.body;
    const hashed = await bcrypt.hash(newPassword || 'reset1234', 10);
    await User.findByIdAndUpdate(req.params.id, { password: hashed, isFirstLogin: true });
    res.json({ message: 'Password reset successfully' });
  } catch (err) { res.status(500).json({ message: err.message }); }
});

module.exports = router;
