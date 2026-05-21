const mongoose = require('mongoose');

const studentSchema = new mongoose.Schema({
  user: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true, unique: true },
  rollNumber: { type: String, required: true, unique: true },
  enrollmentNumber: { type: String, required: true, unique: true },
  department: { type: mongoose.Schema.Types.ObjectId, ref: 'Department', required: true },
  course: { type: mongoose.Schema.Types.ObjectId, ref: 'Course', required: true },
  semester: { type: Number, required: true, min: 1, max: 8 },
  section: { type: String, enum: ['A', 'B', 'C', 'D'], default: 'A' },
  batch: { type: String, required: true },
  academicYear: { type: String, required: true },
  admissionDate: { type: Date, default: Date.now },
  guardianName: String,
  guardianPhone: String,
  guardianEmail: String,
  bloodGroup: { type: String, enum: ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'] },
  category: { type: String, enum: ['general', 'obc', 'sc', 'st', 'other'], default: 'general' },
  feeStatus: { type: String, enum: ['paid', 'partial', 'unpaid', 'overdue'], default: 'unpaid' },
  totalFees: { type: Number, default: 0 },
  feesPaid: { type: Number, default: 0 },
  attendancePercentage: { type: Number, default: 0 },
  cgpa: { type: Number, default: 0 },
  isActive: { type: Boolean, default: true }
}, { timestamps: true, toJSON: { virtuals: true }, toObject: { virtuals: true } });

// studentSchema.index({ rollNumber: 1 });
// studentSchema.index({ enrollmentNumber: 1 });
// studentSchema.index({ department: 1, semester: 1 });
// studentSchema.index({ course: 1 });

module.exports = mongoose.model('Student', studentSchema);