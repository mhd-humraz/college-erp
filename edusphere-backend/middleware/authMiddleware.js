// middleware/authMiddleware.js
const jwt = require('jsonwebtoken');
const User = require('../models/User');

// Verify Access Token Validity
const verifyToken = async (req, res, next) => {
    const authHeader = req.headers['authorization'];
    const token = authHeader && authHeader.split(' ')[1];

    if (!token) return res.status(401).json({ error: "Access token missing or invalid" });

    try {
        const decoded = jwt.verify(token, process.env.JWT_ACCESS_SECRET);
        req.user = await User.findById(decoded.id).select('-password');
        if (!req.user || !req.user.isActive) {
            return res.status(403).json({ error: "User session revoked or deactivated" });
        }
        next();
    } catch (err) {
        return res.status(403).json({ error: "Token expired or corrupted", code: "TOKEN_EXPIRED" });
    }
};

// Role Authorization Interceptor (Dynamic Role Handler)
const authorizeRoles = (...allowedRoles) => {
    return (req, res, next) => {
        if (!req.user || !allowedRoles.includes(req.user.role)) {
            return res.status(403).json({ error: "Access Denied: Insufficient security clearances" });
        }
        next();
    };
};

module.exports = { verifyToken, authorizeRoles };