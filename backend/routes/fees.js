const express = require('express');
const router = express.Router();
const auth = require('../middleware/auth');

// Simple Fee schema inline (or use a model if you prefer)
const mongoose = require('mongoose');

const feeSchema = new mongoose.Schema({
  studentId: { type: String, required: true },
  studentName: { type: String },
  amount: { type: Number, required: true },
  description: { type: String },
  status: { type: String, enum: ['Pending', 'Paid', 'Overdue'], default: 'Pending' },
  dueDate: { type: String },
  paidDate: { type: String },
}, { timestamps: true });

const Fee = mongoose.models.Fee || mongoose.model('Fee', feeSchema);

// GET /api/fees
router.get('/', auth, async (req, res) => {
  try {
    const fees = await Fee.find().sort({ createdAt: -1 });
    res.json(fees);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// GET /api/fees/summary
router.get('/summary', auth, async (req, res) => {
  try {
    const total = await Fee.aggregate([{ $group: { _id: null, total: { $sum: '$amount' } } }]);
    const paid = await Fee.aggregate([{ $match: { status: 'Paid' } }, { $group: { _id: null, total: { $sum: '$amount' } } }]);
    const pending = await Fee.aggregate([{ $match: { status: 'Pending' } }, { $group: { _id: null, total: { $sum: '$amount' } } }]);
    const overdue = await Fee.aggregate([{ $match: { status: 'Overdue' } }, { $group: { _id: null, total: { $sum: '$amount' } } }]);

    res.json({
      total: total[0]?.total ?? 0,
      paid: paid[0]?.total ?? 0,
      pending: pending[0]?.total ?? 0,
      overdue: overdue[0]?.total ?? 0,
    });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// POST /api/fees
router.post('/', auth, async (req, res) => {
  try {
    const fee = await Fee.create(req.body);
    res.status(201).json(fee);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// PUT /api/fees/:id
router.put('/:id', auth, async (req, res) => {
  try {
    const fee = await Fee.findByIdAndUpdate(req.params.id, req.body, { new: true });
    res.json(fee);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// DELETE /api/fees/:id
router.delete('/:id', auth, async (req, res) => {
  try {
    await Fee.findByIdAndDelete(req.params.id);
    res.json({ message: 'Fee record deleted' });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

module.exports = router;