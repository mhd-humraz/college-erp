const express = require('express');
const router = express.Router();
const Course = require('../models/Course');
const auth = require('../middleware/auth');

// GET /api/courses
router.get('/', auth, async (req, res) => {
  try {
    const courses = await Course.find()
      .populate('department', 'name code')
      .populate('teacher', 'name email');
    res.json(courses);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// GET /api/courses/:id
router.get('/:id', auth, async (req, res) => {
  try {
    const course = await Course.findById(req.params.id)
      .populate('department', 'name code')
      .populate('teacher', 'name email');
    if (!course) return res.status(404).json({ message: 'Course not found' });
    res.json(course);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// POST /api/courses
router.post('/', auth, async (req, res) => {
  try {
    const { name, code, description, credits, department, teacher, semester } = req.body;
    const course = await Course.create({
      name, code, description, credits, department, teacher, semester
    });
    res.status(201).json(course);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// PUT /api/courses/:id
router.put('/:id', auth, async (req, res) => {
  try {
    const course = await Course.findByIdAndUpdate(
      req.params.id,
      req.body,
      { new: true }
    );
    res.json(course);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// DELETE /api/courses/:id
router.delete('/:id', auth, async (req, res) => {
  try {
    await Course.findByIdAndDelete(req.params.id);
    res.json({ message: 'Course deleted' });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

module.exports = router;