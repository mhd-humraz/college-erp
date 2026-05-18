const express = require('express');
const router = express.Router();
const Fee = require('../models/Fee');
const auth = require('../middleware/auth');

router.get('/', auth, async (req, res) => {
  try {
    const { status } = req.query;
    const filter = status ? { status } : {};
    res.json(await Fee.find(filter).sort({ createdAt: -1 }));
  } catch (err) { res.status(500).json({ message: err.message }); }
});

router.get('/summary', auth, async (req, res) => {
  try {
    const all = await Fee.find();
    const total = all.reduce((s, f) => s + f.amount, 0);
    const paid = all.filter(f => f.status === 'Paid').reduce((s, f) => s + f.amount, 0);
    const pending = all.filter(f => f.status === 'Pending').reduce((s, f) => s + f.amount, 0);
    const overdue = all.filter(f => f.status === 'Overdue').reduce((s, f) => s + f.amount, 0);
    res.json({ total, paid, pending, overdue });
  } catch (err) { res.status(500).json({ message: err.message }); }
});

router.post('/', auth, async (req, res) => {
  try { res.status(201).json(await Fee.create(req.body)); }
  catch (err) { res.status(500).json({ message: err.message }); }
});

router.put('/:id', auth, async (req, res) => {
  try { res.json(await Fee.findByIdAndUpdate(req.params.id, req.body, { new: true })); }
  catch (err) { res.status(500).json({ message: err.message }); }
});

router.delete('/:id', auth, async (req, res) => {
  try { await Fee.findByIdAndDelete(req.params.id); res.json({ message: 'Deleted' }); }
  catch (err) { res.status(500).json({ message: err.message }); }
});

module.exports = router;
