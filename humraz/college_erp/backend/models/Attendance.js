const mongoose = require('mongoose');

const attendanceSessionSchema = new mongoose.Schema({
  date: { type: Date, required: true },
  subject: { type: mongoose.Schema.Types.ObjectId, ref: 'Subject', required: true },
  teacher: { type: mongoose.Schema.Types.ObjectId, ref: 'Teacher', required: true },
  course: { type: mongoose.Schema.Types.ObjectId, ref: 'Course', required: true },
  semester: { type: Number, required: true },
  section: { type: String, required: true },
  department: { type: mongoose.Schema.Types.ObjectId, ref: 'Department', required: true },
  sessionType: { type: String, enum: ['lecture', 'lab', 'tutorial'], default: 'lecture' },
  period: { type: Number, required: true },
  totalStudents: { type: Number, default: 0 },
  presentCount: { type: Number, default: 0 },
  absentCount: { type: Number, default: 0 },
  records: [{
    student: { type: mongoose.Schema.Types.ObjectId, ref: 'Student', required: true },
    status: { type: String, enum: ['present', 'absent', 'late', 'excused'], required: true },
    remarks: String
  }],
  markedBy: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
  isLocked: { type: Boolean, default: false }
}, { timestamps: true });

attendanceSessionSchema.index({ date: 1, subject: 1, section: 1 });
attendanceSessionSchema.index({ teacher: 1 });
attendanceSessionSchema.index({ 'records.student': 1 });

module.exports = mongoose.model('AttendanceSession', attendanceSessionSchema);