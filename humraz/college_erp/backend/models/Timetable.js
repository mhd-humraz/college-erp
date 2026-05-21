const mongoose = require('mongoose');

const timetableEntrySchema = new mongoose.Schema({
  day: { type: String, enum: ['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday'], required: true },
  period: { type: Number, required: true, min: 1, max: 8 },
  startTime: { type: String, required: true },
  endTime: { type: String, required: true },
  subject: { type: mongoose.Schema.Types.ObjectId, ref: 'Subject', required: true },
  teacher: { type: mongoose.Schema.Types.ObjectId, ref: 'Teacher', required: true },
  course: { type: mongoose.Schema.Types.ObjectId, ref: 'Course', required: true },
  semester: { type: Number, required: true },
  section: { type: String, required: true },
  department: { type: mongoose.Schema.Types.ObjectId, ref: 'Department', required: true },
  roomNumber: { type: String, required: true },
  classType: { type: String, enum: ['lecture', 'lab', 'tutorial'], default: 'lecture' },
  isLab: { type: Boolean, default: false },
  academicYear: { type: String, required: true },
  semesterType: { type: String, enum: ['odd', 'even'], required: true },
  isActive: { type: Boolean, default: true },
  approvedBy: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
  approvalStatus: { type: String, enum: ['pending', 'approved', 'rejected'], default: 'pending' }
}, { timestamps: true });

timetableEntrySchema.index({ day: 1, period: 1, section: 1 });
timetableEntrySchema.index({ course: 1, semester: 1, section: 1 });
timetableEntrySchema.index({ teacher: 1, day: 1 });

module.exports = mongoose.model('TimetableEntry', timetableEntrySchema);