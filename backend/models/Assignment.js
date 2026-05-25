const mongoose = require('mongoose');

const assignmentSchema = new mongoose.Schema({
  title: { type: String, required: true },
  description: { type: String },
  subjectId: { type: mongoose.Schema.Types.ObjectId, ref: 'Subject', required: true },
  teacherId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  classId: { type: mongoose.Schema.Types.ObjectId, ref: 'Class', required: true },
  fileUrl: { type: String }, // PDF/Notes URL
  fileName: { type: String },
  fileType: { type: String, enum: ['pdf', 'doc', 'image', 'other'], default: 'pdf' },
  dueDate: { type: Date, required: true },
  maxMarks: { type: Number, default: 100 },
  isActive: { type: Boolean, default: true },
  totalSubmissions: { type: Number, default: 0 }
}, { timestamps: true });

module.exports = mongoose.model('Assignment', assignmentSchema);