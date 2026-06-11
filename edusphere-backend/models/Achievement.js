// models/Achievement.js
const mongoose = require('mongoose');

const AchievementSchema = new mongoose.Schema({
    student: { type: mongoose.Schema.Types.ObjectId, ref: 'Student', required: true },
    title: { type: String, required: true, trim: true }, // e.g., "Smart India Hackathon Winner"
    category: { type: String, enum: ['Hackathon', 'Certification', 'Sports', 'Research_Paper', 'Project'], required: true },
    issuer: { type: String, required: true, trim: true }, // e.g., "Ministry of Education"
    dateEarned: { type: Date, required: true },
    description: { type: String, required: true },
    verificationUrl: { type: String, trim: true }, // Optional link to credential artifact
    skillsUsed: [{ type: String, trim: true }] // e.g., ["Flutter", "Node.js"]
}, { timestamps: true });

module.exports = mongoose.model('Achievement', AchievementSchema);