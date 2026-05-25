const Notification = require('../models/Notification');
const User = require('../models/User');

// @desc   Create Smart Notification (Targeted)
exports.createNotification = async (req, res) => {
  try {
    const { title, message, targetRole, targetDepartmentId, targetClassId, priority } = req.body;

    const notification = await Notification.create({
      title,
      message,
      senderId: req.user._id,
      targetRole: targetRole || 'all',
      targetDepartmentId,
      targetClassId,
      priority: priority || 'normal'
    });

    // Real-time push notification logic can be added here (Socket.io / Firebase)

    res.status(201).json({ success: true, data: notification, message: 'Notification sent!' });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

// @desc   Get My Notifications (Smart Filtering)
exports.getMyNotifications = async (req, res) => {
  try {
    const user = req.user;
    
    // Build query based on user's role and context
    const query = {
      $or: [
        { targetRole: 'all' },
        { targetRole: user.role },
        { targetRole: null }
      ]
    };

    // Department-level notifications
    if (user.departmentId) {
      query.$or.push(
        { targetDepartmentId: user.departmentId },
        { targetDepartmentId: null }
      );
    }

    // Class-level notifications (for students/class teachers)
    if (user.classId && ['student', 'class_teacher'].includes(user.role)) {
      query.$or.push(
        { targetClassId: user.classId },
        { targetClassId: null }
      );
    }

    const notifications = await Notification.find(query)
      .populate('senderId', 'name role')
      .sort({ createdAt: -1 })
      .limit(50);

    const unreadCount = notifications.filter(n => !n.isRead).length;

    res.json({ 
      success: true, 
      count: notifications.length, 
      unreadCount,
      data: notifications 
    });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

// @desc   Mark as Read
exports.markAsRead = async (req, res) => {
  try {
    const { notificationId } = req.params;
    
    await Notification.findByIdAndUpdate(notificationId, { isRead: true });
    
    res.json({ success: true, message: 'Marked as read' });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

// @desc   Mark All as Read
exports.markAllRead = async (req, res) => {
  try {
    await Notification.updateMany(
      { isRead: false },
      { isRead: true }
    );

    res.json({ success: true, message: 'All marked as read' });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};