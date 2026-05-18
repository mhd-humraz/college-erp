const mongoose = require('mongoose');

const eventSchema = new mongoose.Schema({
  title:       { type: String, required: true },
  date:        { type: String, required: true },
  venue:       { type: String },
  description: { type: String },
  organizer:   { type: String },
  status:      { type: String, enum: ['Upcoming', 'Ongoing', 'Completed'], default: 'Upcoming' },
}, { timestamps: true });

module.exports = mongoose.model('Event', eventSchema);
