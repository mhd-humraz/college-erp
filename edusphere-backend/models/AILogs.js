// models/AILogs.js
const mongoose = require('mongoose');

const AILogSchema = new mongoose.Schema({
    user: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
    userRole: { type: String, required: true },
    query: { type: String, required: true },
    detectedIntent: { type: String },
    resolvedPayload: { type: mongoose.Schema.Types.Mixed }, // Stores database output snippets returned to the AI
    timestamp: { type: Date, default: Date.now }
}, { timestamps: true });

module.exports = mongoose.model('AILog', AILogSchema);