const express = require('express');
const router = express.Router();
const bcrypt = require('bcryptjs');
const User = require('../models/User');
const auth = require('../middleware/auth');

// GET /api/staff - Get all staff members
router.get('/', auth, async (req, res) => {
  try {
    const staff = await User.find({ role: { $in: ['Teacher', 'Staff', 'Admin'] } })
      .select('-password')
      .populate('department', 'name');
    res.json(staff);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// POST /api/staff - Add new staff
router.post('/', auth, async (req, res) => {
  try {
    const { name, email, password, role, phone, department, employeeId } = req.body;
    
    const existing = await User.findOne({ email });
    if (existing) return res.status(400).json({ message: 'Email already exists' });
    
    const hashed = await bcrypt.hash(password, 10);
    const staff = await User.create({
      name,
      email,
      password: hashed,
      role,
      phone,
      department,
      employeeId
    });
    
    res.status(201).json({ message: 'Staff added successfully', staff: staff._id });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// PUT /api/staff/:id - Update staff
router.put('/:id', auth, async (req, res) => {
  try {
    const { name, phone, department, isActive } = req.body;
    const staff = await User.findByIdAndUpdate(
      req.params.id,
      { name, phone, department, isActive },
      { new: true }
    ).select('-password');
    res.json(staff);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// DELETE /api/staff/:id - Remove staff
router.delete('/:id', auth, async (req, res) => {
  try {
    await User.findByIdAndDelete(req.params.id);
    res.json({ message: 'Staff removed successfully' });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

module.exports = router;