const mongoose = require('mongoose');

const marksEntrySchema = new mongoose.Schema({
  exam: { type: mongoose.Schema.Types.ObjectId, ref: 'Exam', required: true },
  subject: { type: mongoose.Schema.Types.ObjectId, ref: 'Subject', required: true },
  student: { type: mongoose.Schema.Types.ObjectId, ref: 'Student', required: true },
  course: { type: mongoose.Schema.Types.ObjectId, ref: 'Course', required: true },
  semester: { type: Number, required: true },
  department: { type: mongoose.Schema.Types.ObjectId, ref: 'Department', required: true },
  marks: {
    internal1: { type: Number, min: 0 },
    internal2: { type: Number, min: 0 },
    assignments: { type: Number, min: 0 },
    practical: { type: Number, min: 0 },
    totalInternal: { type: Number, min: 0 },
    external: { type: Number, min: 0 },
    grandTotal: { type: Number, min: 0 }
  },
  maxMarks: {
    internal1: { type: Number, default: 30 },
    internal2: { type: Number, default: 30 },
    assignments: { type: Number, default: 10 },
    practical: { type: Number, default: 30 },
    external: { type: Number, default: 100 }
  },
  grade: { type: String, enum: ['O', 'A+', 'A', 'B+', 'B', 'C', 'F', 'Absent'] },
  gradePoints: Number,
  result: { type: String, enum: ['pass', 'fail', 'pending'], default: 'pending' },
  enteredBy: { type: mongoose.Schema.Types.ObjectId, ref: 'Teacher' },
  isPublished: { type: Boolean, default: false },
  remarks: String
}, { timestamps: true });

marksEntrySchema.index({ exam: 1, student: 1 });
marksEntrySchema.index({ subject: 1, student: 1 });
marksEntrySchema.index({ student: 1, semester: 1 });

module.exports = mongoose.model('MarksEntry', marksEntrySchema);