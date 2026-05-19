const jwt = require('jsonwebtoken');

module.exports = (req, res, next) => {
  
  // ==========================================
  // Try multiple token sources
  // ==========================================
  
  // Method 1: Standard Bearer token (Authorization: Bearer xxx)
  let token = null;
  const authHeader = req.headers['authorization'];
  
  if (authHeader && authHeader.startsWith('Bearer ')) {
    token = authHeader.split(' ')[1];
  }
  
  // Method 2: Custom x-auth-token header (your friend's Flutter pattern)
  if (!token && req.headers['x-auth-token']) {
    token = req.headers['x-auth-token'];
  }

  // ==========================================
  // No token found
  // ==========================================
  
  if (!token) {
    return res.status(401).json({ 
      message: 'Access denied. No token provided.' 
    });
  }

  // ==========================================
  // Verify token
  // ==========================================
  
  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    req.user = decoded;
    
    console.log(`✅ Authenticated: ${decoded.name} (${decoded.role})`);
    
    next();
  } catch (err) {
    
    if (err.name === 'TokenExpiredError') {
      return res.status(401).json({ 
        message: 'Token expired. Please login again.' 
      });
    }
    
    return res.status(401).json({ 
      message: 'Invalid or expired token.' 
    });
  }
};