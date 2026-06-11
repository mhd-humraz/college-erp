const mongoose = require('mongoose');

const MarksSchema = new mongoose.Schema({
    subject: { type: mongoose.Schema.Types.ObjectId, ref: 'Subject', required: true },
    examType: { type: String, enum: ['Internal_1', 'Internal_2', 'Semester_Final'], required: true },
    maxMarks: { type: Number, default: 100, required: true },
    scores: [{
        student: { type: mongoose.Schema.Types.ObjectId, ref: 'Student', required: true },
        marksObtained: { type: Number, required: true }
    }]
}, { timestamps: true });

module.exports = mongoose.model('Marks', MarksSchema);