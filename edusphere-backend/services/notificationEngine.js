// services/notificationEngine.js
const Notification = require('../models/Notification');
const globalServerInstance = require('../server'); // Pulls socket connections from server entry point

class NotificationEngine {
    /**
     * Broadcasts real-time events and saves persistent notifications to the database
     */
    async dispatchMultiCastNotification({ recipients, title, body, category }) {
        // 1. Map documents for bulk database insertion
        const notificationPayloads = recipients.map(recipientId => ({
            recipient: recipientId,
            title,
            body,
            category
        }));

        await Notification.insertMany(notificationPayloads);

        // 2. Push real-time WebSockets signals if users are actively online
        recipients.forEach(recipientId => {
            if (global.io) {
                global.io.emit(`notification_feed_${recipientId}`, { title, body, category, createdAt: new Date() });
            }
        });
        
        console.log(`🔔 Dispatched ${recipients.length} real-time notifications under category [${category}].`);
    }
}

module.exports = new NotificationEngine();