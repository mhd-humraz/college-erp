const mongoose = require('mongoose');

const timetableSchema = new mongoose.Schema({
  day: {
    type: String,
    enum: ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'],
    required: true,
  },
  subject: { type: String, required: true },
  teacher: { type: String, required: true },
  time: { type: String, required: true },
  room: { type: String },
  department: { type: String },
}, { timestamps: true });

module.exports = mongoose.model('Timetable', timetableSchema);
