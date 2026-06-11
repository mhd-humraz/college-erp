// models/AiInsight.js
const mongoose = require('mongoose');

const AiInsightSchema = new mongoose.Schema({
    student: { type: mongoose.Schema.Types.ObjectId, ref: 'Student', required: true, unique: true },
    currentAttendanceRate: { type: Number, required: true },
    predictedSemesterEndAttendance: { type: Number, required: true },
    academicPerformanceScore: { type: Number, required: true }, // Out of 100 based on internal assessment marks
    hasPendingFees: { type: Boolean, default: false },
    riskLevel: { type: String, enum: ['Low', 'Medium', 'High'], default: 'Low' },
    recommendationText: { type: String, required: true }
}, { timestamps: true });

module.exports = mongoose.model('AiInsight', AiInsightSchema);