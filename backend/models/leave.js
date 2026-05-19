const mongoose = require('mongoose');

const leaveSchema = new mongoose.Schema({
  name: { type: String, required: true },
  date: { type: String, required: true },
  reason: { type: String, required: true },
  approved: { type: Boolean, default: false },
  studentId: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
  teacherId: { type: mongoose.Schema.Types.ObjectId, ref: 'User' }
}, { timestamps: true });

module.exports = mongoose.model('Leave', leaveSchema);