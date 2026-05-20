// backend/middleware/roleAuth.js

const roleAuth = (allowedRoles) => {
  return (req, res, next) => {
    // Safety check: Ensure the auth middleware ran first
    if (!req.user || !req.user.role) {
      return res.status(401).json({ 
        message: 'Authentication required. Please log in.' 
      });
    }

    // Check if the user's role is included in the allowed roles array
    if (!allowedRoles.includes(req.user.role)) {
      return res.status(403).json({ 
        message: `Access denied. Required role: ${allowedRoles.join(' or ')}` 
      });
    }

    next();
  };
};

module.exports = roleAuth;