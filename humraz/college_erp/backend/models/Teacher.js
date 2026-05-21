const mongoose = require('mongoose');

const teacherSchema = new mongoose.Schema({
  user: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true, unique: true },
  employeeId: { type: String, required: true, unique: true },
  department: { type: mongoose.Schema.Types.ObjectId, ref: 'Department', required: true },
  designation: { type: String, required: true, enum: ['professor', 'associate_professor', 'assistant_professor', 'lecturer', 'lab_instructor', 'hod'] },
  qualification: { type: String, required: true },
  specialization: String,
  experience: { type: Number, default: 0 },
  dateOfJoining: { type: Date, required: true },
  subjects: [{ type: mongoose.Schema.Types.ObjectId, ref: 'Subject' }],
  classes: [{ course: { type: mongoose.Schema.Types.ObjectId, ref: 'Course' }, semester: Number, section: String }],
  isHOD: { type: Boolean, default: false },
  salary: Number,
  leaveBalance: { casual: { type: Number, default: 12 }, sick: { type: Number, default: 10 }, earned: { type: Number, default: 15 } },
  performanceRating: { type: Number, min: 0, max: 5, default: 0 },
  totalClassesTaken: { type: Number, default: 0 },
  isActive: { type: Boolean, default: true }
}, { timestamps: true, toJSON: { virtuals: true }, toObject: { virtuals: true } });

// teacherSchema.index({ employeeId: 1 });
// teacherSchema.index({ department: 1 });
// teacherSchema.index({ designation: 1 });

module.exports = mongoose.model('Teacher', teacherSchema);