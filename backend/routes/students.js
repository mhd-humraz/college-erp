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

const upload = multer({ storage });

// GET /api/students
router.get('/', auth, async (req, res) => {
  try {
    const { department, semester } = req.query;
    const filter = { role: 'Student' };
    if (department) filter.department = department;
    if (semester) filter.semester = semester;
    const students = await User.find(filter).select('-password').sort({ studentId: 1 });
    res.json(students);
  } catch (err) { res.status(500).json({ message: err.message }); }
});

// POST /api/students/add - manual
router.post('/add', auth, async (req, res) => {
  try {
    const { name, email, phone, guardianPhone, department, semester, batch, studentId, password } = req.body;
    if (!name || !studentId || !password) {
      return res.status(400).json({ message: 'Name, Student ID and Password are required' });
    }
    const existing = await User.findOne({ studentId: studentId.trim() });
    if (existing) return res.status(400).json({ message: `Student ID "${studentId}" already exists` });

    const hashed = await bcrypt.hash(password.trim(), 10);
    const student = await User.create({
      name: name.trim(), email: email?.trim().toLowerCase(), phone: phone?.trim(),
      guardianPhone: guardianPhone?.trim(), department: department?.trim(),
      semester: semester?.trim(), batch: batch?.trim(),
      studentId: studentId.trim(), password: hashed,
      role: 'Student', isFirstLogin: true, isActive: true,
    });

    res.status(201).json({ message: 'Student added', student: { id: student._id, name: student.name, studentId: student.studentId } });
  } catch (err) { res.status(500).json({ message: err.message }); }
});

// POST /api/students/upload-csv
// CSV: name, email, phone, guardianPhone, department, semester, batch, studentId, password
router.post('/upload-csv', auth, upload.single('file'), async (req, res) => {
  try {
    if (!req.file) return res.status(400).json({ message: 'No CSV file uploaded' });
    const rows = await csv().fromFile(req.file.path);
    const results = { success: 0, failed: 0, errors: [] };

    for (const row of rows) {
      try {
        if (!row.name || !row.studentId || !row.password) {
          results.failed++;
          results.errors.push(`Missing fields: ${JSON.stringify(row)}`);
          continue;
        }
        const existing = await User.findOne({ studentId: row.studentId.trim() });
        if (existing) {
          results.failed++;
          results.errors.push(`Student ID "${row.studentId}" already exists`);
          continue;
        }
        const hashed = await bcrypt.hash(row.password.trim(), 10);
        await User.create({
          name: row.name?.trim(), email: row.email?.trim().toLowerCase(), phone: row.phone?.trim(),
          guardianPhone: row.guardianPhone?.trim(), department: row.department?.trim(),
          semester: row.semester?.trim(), batch: row.batch?.trim(),
          studentId: row.studentId?.trim(), password: hashed,
          role: 'Student', isFirstLogin: true, isActive: true,
        });
        results.success++;
      } catch (rowErr) {
        results.failed++;
        results.errors.push(rowErr.message);
      }
    }

    fs.unlinkSync(req.file.path);
    res.json({ message: `Upload done. ${results.success} added, ${results.failed} failed.`, ...results });
  } catch (err) { res.status(500).json({ message: err.message }); }
});

// DELETE /api/students/:id
router.delete('/:id', auth, async (req, res) => {
  try {
    await User.findByIdAndDelete(req.params.id);
    res.json({ message: 'Student deleted' });
  } catch (err) { res.status(500).json({ message: err.message }); }
});

module.exports = router;
