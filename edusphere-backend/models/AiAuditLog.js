// models/AiAuditLog.js
const mongoose = require('mongoose');

const AiAuditLogSchema = new mongoose.Schema({
    user: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
    userRole: { type: String, required: true },
    rawQuery: { type: String, required: true, trim: true },
    resolvedIntent: { type: String, required: true },
    executionSuccess: { type: Boolean, default: true }
}, { timestamps: true });

module.exports = mongoose.model('AiAuditLog', AiAuditLogSchema);