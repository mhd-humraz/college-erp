const mongoose = require('mongoose');

const requestSchema = new mongoose.Schema({
  type: { type: String, enum: ['add_student', 'remove_student'], default: 'add_student' },
  studentName: { type: String, required: true },
  rollNumber: { type: String },
  classId: { type: mongoose.Schema.Types.ObjectId, ref: 'Class', required: true },
  requestedBy: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  reason: { type: String },
  status: { type: String, enum: ['pending', 'resolved', 'rejected'], default: 'pending' },
  resolvedAt: { type: Date },
  resolvedBy: { type: mongoose.Schema.Types.ObjectId, ref: 'User' }
}, { timestamps: true });

module.exports = mongoose.model('Request', requestSchema);