// models/Academic.js
const mongoose = require('mongoose');

const DepartmentSchema = new mongoose.Schema({
    name: { type: String, required: true, unique: true, trim: true }, // e.g., "Computer Applications"
    code: { type: String, required: true, unique: true, uppercase: true, trim: true } // e.g., "BCA"
}, { timestamps: true });

const CourseSchema = new mongoose.Schema({
    name: { type: String, required: true, trim: true }, // e.g., "Bachelor of Computer Applications"
    department: { type: mongoose.Schema.Types.ObjectId, ref: 'Department', required: true },
    durationYears: { type: Number, default: 3 }
}, { timestamps: true });

const SubjectSchema = new mongoose.Schema({
    name: { type: String, required: true, trim: true },
    code: { type: String, required: true, unique: true, uppercase: true },
    course: { type: mongoose.Schema.Types.ObjectId, ref: 'Course', required: true },
    semester: { type: Number, required: true } // e.g., Semester 1 to 6
}, { timestamps: true });

module.exports = {
    Department: mongoose.model('Department', DepartmentSchema),
    Course: mongoose.model('Course', CourseSchema),
    Subject: mongoose.model('Subject', SubjectSchema)
};