const mongoose = require('mongoose');

const settingsSchema = new mongoose.Schema({
  collegeName:           { type: String, default: 'MESCAS' },
  email:                 { type: String, default: '' },
  phone:                 { type: String, default: '' },
  address:               { type: String, default: '' },
  academicYear:          { type: String, default: '2024-2025' },
  notificationsEnabled:  { type: Boolean, default: true },
  maintenanceMode:       { type: Boolean, default: false },
}, { timestamps: true });

module.exports = mongoose.model('Settings', settingsSchema);
