const mongoose = require('mongoose');

const courseSchema = new mongoose.Schema({
  name:        { type: String, required: true, trim: true },
  code:        { type: String, required: true, uppercase: true },
  credits:     { type: Number, required: true },
  semester:    { type: Number },
  department:  { type: String },
  teacher:     { type: String },
  teacherId:   { type: String },
  type:        { type: String, enum: ['Core', 'Elective'], default: 'Core' },
  description: { type: String },
}, { timestamps: true });

module.exports = mongoose.model('Course', courseSchema);
