// models/Notification.js
const mongoose = require('mongoose');

const NotificationSchema = new mongoose.Schema({
    recipient: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
    title: { type: String, required: true },
    body: { type: String, required: true },
    category: { type: String, enum: ['Academic', 'Finance', 'Grievance', 'System'], required: true },
    isRead: { type: Boolean, default: false }
}, { timestamps: true });

// Optimize lookups for unread notifications on user dashboards
NotificationSchema.index({ recipient: 1, isRead: 1 });

module.exports = mongoose.model('Notification', NotificationSchema);