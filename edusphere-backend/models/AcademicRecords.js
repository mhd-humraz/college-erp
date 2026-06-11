// models/AcademicRecords.js
const mongoose = require('mongoose');

// Keeps track of the specific class session a teacher takes
const AttendanceSessionSchema = new mongoose.Schema({
    subject: { type: mongoose.Schema.Types.ObjectId, ref: 'Subject', required: true },
    teacher: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
    date: { type: Date, required: true, default: Date.now },
    hour: { type: Number, required: true } // e.g., Hour 1, Hour 2
}, { timestamps: true });

const AttendanceSchema = new mongoose.Schema({
    session: { type: mongoose.Schema.Types.ObjectId, ref: 'AttendanceSession', required: true },
    student: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
    isPresent: { type: Boolean, required: true, default: true }
}, { timestamps: true });

const MarksSchema = new mongoose.Schema({
    student: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
    subject: { type: mongoose.Schema.Types.ObjectId, ref: 'Subject', required: true },
    examType: { type: String, required: true, enum: ['Internal_1', 'Internal_2', 'Semester_Final'] },
    marksObtained: { type: Number, required: true },
    maxMarks: { type: Number, required: true, default: 100 }
}, { timestamps: true });

module.exports = {
    AttendanceSession: mongoose.model('AttendanceSession', AttendanceSessionSchema),
    Attendance: mongoose.model('Attendance', AttendanceSchema),
    Marks: mongoose.model('Marks', MarksSchema)
};