const jwt = require('jsonwebtoken');

module.exports = (req, res, next) => {
    // Check for token in multiple locations
    const token = req.headers['x-auth-token'] ||
        req.headers['authorization']?.split(' ')[1];

    if (!token) {
        return res.status(401).json({ message: 'Access denied. No token provided.' });
    }

    // First try normal JWT verification
    try {
        const decoded = jwt.verify(token, process.env.JWT_SECRET);
        req.user = decoded;

        // Check if user has admin role
        if (decoded.role !== 'Admin') {
            return res.status(403).json({ message: 'Admin access required.' });
        }
        next();
    } catch (err) {
        // If normal verification fails, check for admin token
        if (token === process.env.ADMIN_TOKEN) {
            const decoded = jwt.decode(token);
            if (decoded && decoded.role === 'Admin') {
                req.user = decoded;
                req.isAdminToken = true;
                next();
            } else {
                return res.status(401).json({ message: 'Invalid admin token.' });
            }
        } else {
            return res.status(401).json({ message: 'Invalid or expired token.' });
        }
    }
};