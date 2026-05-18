const mongoose = require('mongoose');

const examSchema = new mongoose.Schema({
  name:       { type: String, required: true },
  date:       { type: String, required: true },
  department: { type: String, required: true },
  semester:   { type: String, required: true },
  subject:    { type: String },
  duration:   { type: String },
  maxMarks:   { type: Number, default: 100 },
  status:     { type: String, enum: ['Upcoming', 'Ongoing', 'Completed'], default: 'Upcoming' },
}, { timestamps: true });

module.exports = mongoose.model('Exam', examSchema);
