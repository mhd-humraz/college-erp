const mongoose = require('mongoose');

const materialSchema = new mongoose.Schema({
  title: { type: String, required: true },
  subject: { type: String, required: true },
  link: { type: String, required: true },
  department: { type: String },
  semester: { type: String },
  teacherId: { type: mongoose.Schema.Types.ObjectId, ref: 'User' }
}, { timestamps: true });

module.exports = mongoose.model('Material', materialSchema);