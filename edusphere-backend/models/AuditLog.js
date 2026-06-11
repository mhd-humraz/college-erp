// models/AuditLog.js
const mongoose = require('mongoose');

const AuditLogSchema = new mongoose.Schema({
    user: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
    role: { type: String, required: true },
    action: { type: String, required: true }, // e.g., 'UPDATE_MARK', 'CREATE_USER'
    target: { type: String, required: true }, // Description of altered document coordinates
    status: { type: String, enum: ['Success', 'Failure'], required: true },
    ipAddress: { type: String },
    userAgent: { type: String }
}, { timestamps: true });

module.exports = mongoose.model('AuditLog', AuditLogSchema);