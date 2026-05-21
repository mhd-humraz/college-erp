const mongoose = require('mongoose');

const departmentSchema = new mongoose.Schema({
  name: { type: String, required: true, unique: true, trim: true },
  code: { type: String, required: true, unique: true, uppercase: true },
  hod: { type: mongoose.Schema.Types.ObjectId, ref: 'Teacher' },
  description: String,
  establishedYear: Number,
  totalStudents: { type: Number, default: 0 },
  totalFaculty: { type: Number, default: 0 },
  courses: [{ type: mongoose.Schema.Types.ObjectId, ref: 'Course' }],
  contactEmail: String,
  contactPhone: String,
  location: { building: String, floor: String, roomNumber: String },
  accreditationStatus: { type: String, enum: ['accredited', 'provisional', 'not_accredited'], default: 'not_accredited' },
  isActive: { type: Boolean, default: true }
}, { timestamps: true, toJSON: { virtuals: true }, toObject: { virtuals: true } });

departmentSchema.index({ code: 1 });
module.exports = mongoose.model('Department', departmentSchema);