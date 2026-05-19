const mongoose = require('mongoose');

const timetableSchema = new mongoose.Schema({
  day:         { type: String, enum: ['Monday','Tuesday','Wednesday','Thursday','Friday','Saturday'], required: true },
  subject:     { type: String, required: true },
  teacherId:   { type: String, required: true },
  teacherName: { type: String },
  time:        { type: String, required: true },
  room:        { type: String },
  department:  { type: String, required: true },
  semester:    { type: String, required: true },
}, { timestamps: true });

module.exports = mongoose.model('Timetable', timetableSchema);
