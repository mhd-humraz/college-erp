const mongoose = require('mongoose');

const markSchema = new mongoose.Schema({
  examName: { type: String, required: true },
  subject: { type: String, required: true },
  department: { type: String, required: true },
  semester: { type: String, required: true },
  records: [{
    studentId: { type: String, required: true },
    marks: { type: Number, default: 0 }
  }],
  teacherId: { type: mongoose.Schema.Types.ObjectId, ref: 'User' }
}, { timestamps: true });

module.exports = mongoose.model('Mark', markSchema);