const mongoose = require('mongoose');

const courseSchema = new mongoose.Schema({
  name: { type: String, required: true, trim: true },
  code: { type: String, required: true, unique: true },
  department: { type: mongoose.Schema.Types.ObjectId, ref: 'Department', required: true },
  duration: { type: Number, required: true, min: 1, max: 6 },
  totalSemesters: { type: Number, default: function() { return this.duration * 2; } },
  degreeType: { type: String, enum: ['bachelors', 'masters', 'diploma', 'phd', 'certificate'], required: true },
  intakeCapacity: { type: Number, default: 60 },
  currentEnrollment: { type: Number, default: 0 },
  feeStructure: {
    tuitionFee: { type: Number, default: 0 },
    developmentFee: { type: Number, default: 0 },
    examFee: { type: Number, default: 0 },
    libraryFee: { type: Number, default: 0 },
    labFee: { type: Number, default: 0 },
    otherFee: { type: Number, default: 0 },
    totalFee: { type: Number, default: 0 }
  },
  accreditation: { status: { type: String, enum: ['NBA', 'NAAC', 'AICTE', 'none'], default: 'none' }, validUntil: Date, grade: String },
  subjects: [{ type: mongoose.Schema.Types.ObjectId, ref: 'Subject' }],
  isActive: { type: Boolean, default: true }
}, { timestamps: true, toJSON: { virtuals: true }, toObject: { virtuals: true } });

// courseSchema.index({ code: 1 });
// courseSchema.index({ department: 1 });
module.exports = mongoose.model('Course', courseSchema);