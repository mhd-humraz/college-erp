const express = require('express');
const router = express.Router();
const Timetable = require('../models/Timetable');
const auth = require('../middleware/auth');

router.get('/', auth, async (req, res) => {
  try {
    const timetable = await Timetable.find().sort({ day: 1 });
    res.json(timetable);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

router.post('/', auth, async (req, res) => {
  try {
    const slot = await Timetable.create(req.body);
    res.status(201).json(slot);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

router.delete('/:id', auth, async (req, res) => {
  try {
    await Timetable.findByIdAndDelete(req.params.id);
    res.json({ message: 'Slot deleted' });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

module.exports = router;