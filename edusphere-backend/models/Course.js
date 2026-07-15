const mongoose = require('mongoose');

const CourseSchema = new mongoose.Schema({
    name: { type: String, required: true, trim: true },
    department: { type: mongoose.Schema.Types.ObjectId, ref: 'Department', required: true },
    totalSemesters: { type: Number, default: 6, required: true }
}, { timestamps: true });

module.exports = mongoose.model('Course', CourseSchema);