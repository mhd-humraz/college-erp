const mongoose = require('mongoose');

const assignmentSchema = new mongoose.Schema({
  title: { type: String, required: true, trim: true },
  description: { type: String, required: true },
  subject: { type: mongoose.Schema.Types.ObjectId, ref: 'Subject', required: true },
  teacher: { type: mongoose.Schema.Types.ObjectId, ref: 'Teacher', required: true },
  course: { type: mongoose.Schema.Types.ObjectId, ref: 'Course', required: true },
  semester: { type: Number, required: true },
  section: { type: String, required: true },
  department: { type: mongoose.Schema.Types.ObjectId, ref: 'Department', required: true },
  dueDate: { type: Date, required: true },
  assignedDate: { type: Date, default: Date.now },
  maxMarks: { type: Number, default: 100 },
  attachments: [{ fileName: String, fileUrl: String, fileSize: Number, uploadedAt: { type: Date, default: Date.now } }],
  submissions: [{
    student: { type: mongoose.Schema.Types.ObjectId, ref: 'Student' },
    submittedAt: Date,
    attachments: [{ fileName: String, fileUrl: String, fileSize: Number }],
    marks: Number,
    feedback: String,
    status: { type: String, enum: ['submitted', 'late_submitted', 'evaluated', 'not_submitted'], default: 'not_submitted' },
    submittedLate: { type: Boolean, default: false }
  }],
  totalSubmissions: { type: Number, default: 0 },
  evaluatedCount: { type: Number, default: 0 },
  status: { type: String, enum: ['active', 'closed', 'expired'], default: 'active' }
}, { timestamps: true, toJSON: { virtuals: true }, toObject: { virtuals: true } });

assignmentSchema.index({ subject: 1, dueDate: -1 });
assignmentSchema.index({ teacher: 1 });
assignmentSchema.index({ 'submissions.student': 1 });

module.exports = mongoose.model('Assignment', assignmentSchema);