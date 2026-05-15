const mongoose = require('mongoose');

const courseSchema = new mongoose.Schema({
  name: { type: String, required: true, trim: true },
  code: { type: String, required: true, unique: true, uppercase: true },
  credits: { type: Number, required: true },
  department: { type: String },
  description: { type: String },
}, { timestamps: true });

module.exports = mongoose.model('Course', courseSchema);
