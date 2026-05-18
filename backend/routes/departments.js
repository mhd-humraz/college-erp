const express = require('express');
const router = express.Router();
const Department = require('../models/Department');
const auth = require('../middleware/auth');

// GET /api/departments
router.get('/', auth, async (req, res) => {
  try {
    const departments = await Department.find().populate('head', 'name email');
    res.json(departments);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// POST /api/departments
router.post('/', auth, async (req, res) => {
  try {
    const department = await Department.create(req.body);
    res.status(201).json(department);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// PUT /api/departments/:id
router.put('/:id', auth, async (req, res) => {
  try {
    const department = await Department.findByIdAndUpdate(
      req.params.id,
      req.body,
      { new: true }
    );
    res.json(department);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// DELETE /api/departments/:id
router.delete('/:id', auth, async (req, res) => {
  try {
    await Department.findByIdAndDelete(req.params.id);
    res.json({ message: 'Department deleted' });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

module.exports = router;