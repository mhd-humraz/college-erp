
const mongoose = require('mongoose');

const subjectSchema = new mongoose.Schema({
  name: { type: String, required: true },
  code: { type: String, required: true, unique: true },
  departmentId: { type: mongoose.Schema.Types.ObjectId, ref: 'Department', required: true },
  classId: { type: mongoose.Schema.Types.ObjectId, ref: 'Class' },
  teacherId: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
  semester: { type: Number },
  credits: { type: Number, default: 3 },
  type: { type: String, enum: ['theory', 'lab'], default: 'theory' }
}, { timestamps: true });

module.exports = mongoose.model('Subject', subjectSchema);