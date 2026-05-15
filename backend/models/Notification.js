const mongoose = require('mongoose');

const notificationSchema = new mongoose.Schema({
  title: { type: String, required: true },
  message: { type: String, required: true },
  target: {
    type: String,
    enum: ['All', 'Student', 'Teacher', 'HOD', 'Principal'],
    default: 'All',
  },
  sentBy: { type: String },
}, { timestamps: true });

module.exports = mongoose.model('Notification', notificationSchema);
