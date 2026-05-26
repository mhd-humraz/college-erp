const AuditLog = require('../models/AuditLog');

// Middleware to log all actions
exports.auditLogger = (action, module) => {
  return async (req, res, next) => {
    const originalJson = res.json.bind(res);
    
    res.json = function(data) {
      // Log successful operations
      if (data.success !== false && req.user) {
        AuditLog.create({
          userId: req.user._id,
          userName: req.user.name,
          userRole: req.user.role,
          action,
          module,
          description: getActionDescription(action, module, req),
          newData: req.body,
          ipAddress: req.ip,
          userAgent: req.get('User-Agent'),
          departmentId: req.user.departmentId
        }).catch(err => console.error('Audit Log Error:', err));
      }

      return originalJson(data);
    };
    
    next();
  };
};

// @desc   Get Audit Logs (Admin/HOD)
exports.getAuditLogs = async (req, res) => {
  try {
    const { page = 1, limit = 20, action, module, userId, startDate, endDate } = req.query;
    
    const query = {};
    if (action) query.action = action;
    if (module) query.module = module;
    if (userId) query.userId = userId;
    if (startDate || endDate) {
      query.createdAt = {};
      if (startDate) query.createdAt.$gte = new Date(startDate);
      if (endDate) query.createdAt.$lte = new Date(endDate);
    }

    // HOD can only see department logs
    if (req.user.role === 'hod') {
      query.departmentId = req.user.departmentId;
    }

    const logs = await AuditLog.find(query)
      .sort({ createdAt: -1 })
      .skip((page - 1) * limit)
      .limit(parseInt(limit));

    const total = await AuditLog.countDocuments(query);

    res.json({
      success: true,
      data: logs,
      pagination: {
        page: parseInt(page),
        pages: Math.ceil(total / limit),
        total
      }
    });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

function getActionDescription(action, module, req) {
  const descriptions = {
    'LOGIN': `${req.user.name} logged in`,
    'LOGOUT': `${req.user.name} logged out`,
    'CREATE': `${req.user.name} created ${module}`,
    'UPDATE': `${req.user.name} updated ${module}`,
    'DELETE': `${req.user.name} deleted ${module}`,
    'UPLOAD': `${req.user.name} uploaded ${module}`
  };
  return descriptions[action] || `${req.user.name} performed ${action} on ${module}`;
}