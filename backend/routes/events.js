const express = require('express');
const router = express.Router();
const Event = require('../models/Event');
const auth = require('../middleware/auth');

router.get('/', auth, async (req, res) => {
  try { res.json(await Event.find().sort({ date: -1 })); }
  catch (err) { res.status(500).json({ message: err.message }); }
});

router.post('/', auth, async (req, res) => {
  try { res.status(201).json(await Event.create({ ...req.body, organizer: req.user.name })); }
  catch (err) { res.status(500).json({ message: err.message }); }
});

router.put('/:id', auth, async (req, res) => {
  try { res.json(await Event.findByIdAndUpdate(req.params.id, req.body, { new: true })); }
  catch (err) { res.status(500).json({ message: err.message }); }
});

router.delete('/:id', auth, async (req, res) => {
  try { await Event.findByIdAndDelete(req.params.id); res.json({ message: 'Event deleted' }); }
  catch (err) { res.status(500).json({ message: err.message }); }
});

module.exports = router;
