const mongoose = require('mongoose');

const FacultySchema = new mongoose.Schema({
    user: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true, unique: true },
    employeeId: { type: String, required: true, unique: true, uppercase: true, trim: true },
    department: { type: mongoose.Schema.Types.ObjectId, ref: 'Department', required: true },
    designation: { type: String, required: true, trim: true } // e.g., "Assistant Professor"
}, { timestamps: true });

module.exports = mongoose.model('Faculty', FacultySchema);