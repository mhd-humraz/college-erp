// services/auditLogger.js
const AuditLog = require('../models/AuditLog');

class AuditLogger {
    static async logAction({ user, role, action, target, status, ipAddress, userAgent }) {
        try {
            await AuditLog.create({
                user,
                role,
                action,
                target,
                status,
                ipAddress: ipAddress || '127.0.0.1',
                userAgent: userAgent || 'Internal system process engine'
            });
        } catch (err) {
            console.error(`🔴 Critical Error: Failed to commit security audit log trail: ${err.message}`);
        }
    }
}

module.exports = AuditLogger;