const mongoose = require('mongoose');

const auditLogSchema = new mongoose.Schema({
  userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  userName: { type: String, required: true },
  userRole: { type: String, required: true },
  action: { type: String, required: true }, // CREATE, UPDATE, DELETE, LOGIN, LOGOUT, UPLOAD
  module: { type: String, required: true }, // User, Department, Attendance, Marks, etc.
  description: { type: String, required: true },
  previousData: { type: mongoose.Schema.Types.Mixed }, // For UPDATE actions
  newData: { type: mongoose.Schema.Types.Mixed }, // For CREATE/UPDATE
  ipAddress: { type: String },
  userAgent: { type: String },
  departmentId: { type: mongoose.Schema.Types.ObjectId, ref: 'Department' },
}, { timestamps: true });

// Index for faster queries
auditLogSchema.index({ userId: 1, createdAt: -1 });
auditLogSchema.index({ userRole: 1, createdAt: -1 });
auditLogSchema.index({ action: 1 });

module.exports = mongoose.model('AuditLog', auditLogSchema);