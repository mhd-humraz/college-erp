const mongoose = require('mongoose');

const feeSchema = new mongoose.Schema({
  studentId:   { type: String, required: true },
  studentName: { type: String },
  amount:      { type: Number, required: true },
  description: { type: String },
  status:      { type: String, enum: ['Pending', 'Paid', 'Overdue'], default: 'Pending' },
  dueDate:     { type: String },
  paidDate:    { type: String },
}, { timestamps: true });

module.exports = mongoose.model('Fee', feeSchema);
