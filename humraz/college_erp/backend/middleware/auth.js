const jwt = require('jsonwebtoken');
const User = require('../models/User');
const Teacher = require('../models/Teacher');

// ============================================
// PROTECT MIDDLEWARE - Requires valid JWT token
// ============================================
const protect = async (req, res, next) => {
  let token;

  if (
    req.headers.authorization &&
    req.headers.authorization.startsWith('Bearer')
  ) {
    try {
      token = req.headers.authorization.split(' ')[1];
      const decoded = jwt.verify(token, process.env.JWT_SECRET);
      
      // Convert to plain object so role is accessible as string
      const userDoc = await User.findById(decoded.id).select('-password');
      
      if (!userDoc) {
        return res.status(401).json({
          success: false,
          message: 'User not found',
          errorCode: 'USER_NOT_FOUND'
        });
      }

      if (!userDoc.isActive) {
        return res.status(401).json({
          success: false,
          message: 'Account has been deactivated',
          errorCode: 'ACCOUNT_DEACTIVATED'
        });
      }

      // CRITICAL: Convert to plain object!
      req.user = userDoc.toObject();
      req.userId = userDoc._id.toString();
      req.userEmail = userDoc.email;
      req.userRole = userDoc.role; // ✅ Now it's a string!

      console.log(`🔐 Authenticated: ${userDoc.email} (Role: ${userDoc.role})`);
      
      next();
    } catch (error) {
      let errorMessage = 'Not authorized to access this route';
      let errorCode = 'TOKEN_INVALID';
      
      if (error.name === 'TokenExpiredError') {
        errorMessage = 'Token expired, please login again';
        errorCode = 'TOKEN_EXPIRED';
      } else if (error.name === 'JsonWebTokenError') {
        errorMessage = 'Invalid token';
        errorCode = 'TOKEN_INVALID';
      }

      return res.status(401).json({
        success: false,
        message: errorMessage,
        errorCode: errorCode
      });
    }
  } else {
    return res.status(401).json({
      success: false,
      message: 'No token provided',
      errorCode: 'NO_TOKEN'
    });
  }
};

// ============================================
// AUTHORIZE MIDDLEWARE - Checks role + HOD profile
// ============================================
const authorize = (...roles) => {
  return async (req, res, next) => {
    try {
      // Ensure user is authenticated (protect middleware should have run already)
      if (!req.user) {
        return res.status(401).json({
          success: false,
          message: 'Authentication required',
          errorCode: 'AUTH_REQUIRED'
        });
      }

      console.log(`🔑 Authorization check for role(s): ${roles.join(', ')}`);
      console.log(`   User: ${req.userEmail} | Role: ${req.userRole}`);

      // CHECK 1: Standard role check (admin, student, etc.)
      if (roles.includes(req.userRole)) {
        console.log(`✅ Access granted: Standard role match (${req.userRole})`);
        return next();
      }

      // CHECK 2: Special HOD check (role is 'teacher' but isHOD=true in profile)
      if (roles.includes('hod')) {
        console.log('🔍 Checking HOD status...');
        
        // Only check Teacher profile if user is a teacher
        if (req.userRole === 'teacher') {
          const teacherProfile = await Teacher.findOne({ user: req.userId });
          
          if (teacherProfile && teacherProfile.isHOD) {
            console.log('✅ HOD access granted! Department:', teacherProfile.department);
            
            // Attach HOD info to request
            req.isHOD = true;
            req.hodDepartment = teacherProfile.department?._id?.toString() || null;
            req.hodDepartmentName = teacherProfile.department?.name || 'Unknown';
            
            return next();
          } else {
            console.log('❌ Not an HOD (isHOD: false or no Teacher profile found)');
          }
        }
        
        // If role is 'hod' directly (unlikely but handle it)
        if (req.userRole === 'hod') {
          console.log('✅ Direct HOD role detected');
          req.isHOD = true;
          return next();
        }
      }

      // CHECK 3: Admin can access everything
      if (roles.includes('admin') && req.userRole === 'admin') {
        console.log('✅ Admin access granted (admin can access all routes)');
        return next();
      }

      // None of the checks passed - ACCESS DENIED
      console.log(`❌ Access DENIED for role: ${req.userRole} for required roles: ${roles.join(', ')}`);

      return res.status(403).json({
        success: false,
        message: 'Access denied. Insufficient privileges.',
        details: {
          yourRole: req.userRole,
          requiredRoles: roles,
          userId: req.userId,
          userEmail: req.userEmail,
          isHOD: req.isHOD || false
        },
        hint: `Your role '${req.userRole}' does not have permission to access this resource.`,
        errorCode: 'INSUFFICIENT_PRIVILEGES'
      });

    } catch (error) {
      console.error('❌ Authorization error:', error);

      return res.status(500).json({
        success: false,
        message: 'Authorization check failed',
        error: process.env.NODE_ENV === 'development' ? error.message : 'Internal error'
      });
    }
  };
};

// ============================================
// OPTIONAL AUTH - No token required (for public endpoints)
// ============================================
const optionalAuth = async (req, res, next) => {
  let token;

  if (req.headers.authorization && req.headers.authorization.startsWith('Bearer')) {
    try {
      token = req.headers.authorization.split(' ')[1];
      const decoded = jwt.verify(token, process.env.JWT_SECRET);
      
      const userDoc = await User.findById(decoded.id).select('-password');
      
      if (userDoc && userDoc.isActive) {
        req.user = userDoc.toObject();
      }
      
    } catch (error) {
      // Token invalid - continue as anonymous
    }
  }

  next();
};

// ============================================
// ADMIN ONLY - Super admin routes
// ============================================
const adminOnly = async (req, res, next) => {
  if (req.user && req.userRole === 'admin') {
    return next();
  }

  return res.status(403).json({
    success: false,
    message: 'Admin access only',
    errorCode: 'ADMIN_ONLY'
  });
};

// ============================================
// EXPORT ALL FUNCTIONS
// ============================================
module.exports = {
  protect,
  authorize,
  optionalAuth,
  adminOnly
};