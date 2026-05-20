const mongoose = require('mongoose');

const assignmentSchema = new mongoose.Schema({
  title: { type: String, required: true },
  subject: { type: String, required: true },
  description: { type: String, required: true },
  department: { type: String },
  semester: { type: String },
  teacherId: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
  dueDate: { type: Date },
  fileUrl: { type: String }
}, { timestamps: true });

module.exports = mongoose.model('Assignment', assignmentSchema);