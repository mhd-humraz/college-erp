const mongoose = require('mongoose');

const AssignmentSchema = new mongoose.Schema({
    subject: { type: mongoose.Schema.Types.ObjectId, ref: 'Subject', required: true },
    faculty: { type: mongoose.Schema.Types.ObjectId, ref: 'Faculty', required: true },
    title: { type: String, required: true, trim: true },
    description: { type: String, trim: true },
    deadline: { type: Date, required: true },
    submissions: [{
        student: { type: mongoose.Schema.Types.ObjectId, ref: 'Student', required: true },
        fileUrl: { type: String, required: true },
        submittedAt: { type: Date, default: Date.now }
    }]
}, { timestamps: true });

module.exports = mongoose.model('Assignment', AssignmentSchema);