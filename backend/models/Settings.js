const mongoose = require('mongoose');

const settingsSchema = new mongoose.Schema({
  collegeName: { type: String, default: 'MESCAS' },
  email: { type: String, default: '' },
  phone: { type: String, default: '' },
  notificationsEnabled: { type: Boolean, default: true },
  maintenanceMode: { type: Boolean, default: false },
}, { timestamps: true });

module.exports = mongoose.model('Settings', settingsSchema);
