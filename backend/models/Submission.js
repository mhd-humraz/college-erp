const mongoose = require('mongoose');

const submissionSchema = new mongoose.Schema({
  assignmentId: { type: mongoose.Schema.Types.ObjectId, ref: 'Assignment', required: true },
  studentId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  fileUrl: { type: String, required: true },
  fileName: { type: String, required: true },
  submittedAt: { type: Date, default: Date.now },
  marks: { type: Number },
  feedback: { type: String },
  status: { 
    type: String, 
    enum: ['submitted', 'late', 'graded', 'returned'],
    default: 'submitted' 
  },
  isLate: { type: Boolean, default: false }
}, { timestamps: true });

submissionSchema.index({ assignmentId: 1, studentId: 1 }, { unique: true });

module.exports = mongoose.model('Submission', submissionSchema);