const mongoose = require('mongoose');

const notificationSchema = new mongoose.Schema({
  title: { type: String, required: true },
  message: { type: String, required: true },
  senderId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  targetRole: { type: String, enum: ['admin', 'hod', 'teacher', 'class_teacher', 'student', 'all'] },
  targetDepartmentId: { type: mongoose.Schema.Types.ObjectId, ref: 'Department' },
  targetClassId: { type: mongoose.Schema.Types.ObjectId, ref: 'Class' },
  isRead: { type: Boolean, default: false }
}, { timestamps: true });

module.exports = mongoose.model('Notification', notificationSchema);