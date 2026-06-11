const mongoose = require('mongoose');

const AttendanceSchema = new mongoose.Schema({
    subject: { type: mongoose.Schema.Types.ObjectId, ref: 'Subject', required: true },
    faculty: { type: mongoose.Schema.Types.ObjectId, ref: 'Faculty', required: true },
    date: { type: Date, required: true, default: Date.now },
    hour: { type: Number, required: true },
    records: [{
        student: { type: mongoose.Schema.Types.ObjectId, ref: 'Student', required: true },
        isPresent: { type: Boolean, required: true, default: true }
    }]
}, { timestamps: true });

module.exports = mongoose.model('Attendance', AttendanceSchema);