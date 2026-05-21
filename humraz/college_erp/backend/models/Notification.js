const mongoose = require('mongoose');

const notificationSchema = new mongoose.Schema({
  title: { type: String, required: true, trim: true },
  message: { type: String, required: true },
  type: { type: String, enum: ['announcement', 'alert', 'reminder', 'fee', 'exam', 'event', 'general', 'urgent'], default: 'general' },
  priority: { type: String, enum: ['low', 'medium', 'high', 'critical'], default: 'medium' },
  sender: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  senderRole: { type: String, required: true },
  targetAudience: { type: String, enum: ['all', 'students', 'teachers', 'department', 'course', 'specific', 'admin', 'hod', 'principal'], required: true },
  targetDepartments: [{ type: mongoose.Schema.Types.ObjectId, ref: 'Department' }],
  targetCourses: [{ type: mongoose.Schema.Types.ObjectId, ref: 'Course' }],
  targetSemesters: [Number],
  targetUsers: [{ type: mongoose.Schema.Types.ObjectId, ref: 'User' }],
  attachments: [{ fileName: String, fileUrl: String }],
  actionRequired: { type: Boolean, default: false },
  actionUrl: String,
  readBy: [{ user: { type: mongoose.Schema.Types.ObjectId, ref: 'User' }, readAt: { type: Date, default: Date.now } }],
  deliveredTo: [{ type: mongoose.Schema.Types.ObjectId, ref: 'User' }],
  isActive: { type: Boolean, default: true },
  scheduledFor: Date,
  expiresAt: Date
}, { timestamps: true });

notificationSchema.index({ createdAt: -1 });
notificationSchema.index({ sender: 1 });
notificationSchema.index({ targetAudience: 1 });
notificationSchema.index({ 'readBy.user': 1 });

module.exports = mongoose.model('Notification', notificationSchema);