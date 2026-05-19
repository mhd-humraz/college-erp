const express = require('express');
const router = express.Router();
const Department = require('../models/Department');
const adminAuth = require('../middleware/adminAuth'); // ← CHANGED from 'auth'

// All routes now use adminAuth instead of auth
router.get('/', adminAuth, async (req, res) => {
  try {
    res.json(await Department.find().sort({ name: 1 }));
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

router.post('/', adminAuth, async (req, res) => {
  try {
    res.status(201).json(await Department.create(req.body));
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

router.put('/:id', adminAuth, async (req, res) => {
  try {
    res.json(await Department.findByIdAndUpdate(req.params.id, req.body, { new: true }));
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

router.delete('/:id', adminAuth, async (req, res) => {
  try {
    await Department.findByIdAndDelete(req.params.id);
    res.json({ message: 'Deleted' });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

module.exports = router;