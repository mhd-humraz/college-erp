const mongoose = require('mongoose');

const attendanceSchema = new mongoose.Schema({
  date:        { type: String, required: true },
  subject:     { type: String, required: true },
  department:  { type: String, required: true },
  semester:    { type: String, required: true },
  teacherId:   { type: String, required: true },
  teacherName: { type: String },
  records: [{
    studentId:   { type: String, required: true },
    studentName: { type: String },
    email:       { type: String },
    guardianPhone:{ type: String },
    status:      { type: String, enum: ['Present', 'Absent'], default: 'Present' },
  }],
}, { timestamps: true });

attendanceSchema.index({ date: 1, subject: 1, department: 1, semester: 1 }, { unique: true });

module.exports = mongoose.model('Attendance', attendanceSchema);
