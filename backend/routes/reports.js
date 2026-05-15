const express = require('express');
const router = express.Router();
const User = require('../models/User');
const Course = require('../models/Course');
const Department = require('../models/Department');
const Notification = require('../models/Notification');
const auth = require('../middleware/auth');

// GET /api/reports/summary
router.get('/summary', auth, async (req, res) => {
  try {
    const totalStudents = await User.countDocuments({ role: 'Student' });
    const totalTeachers = await User.countDocuments({ role: 'Teacher' });
    const totalDepartments = await Department.countDocuments();
    const totalCourses = await Course.countDocuments();

    const recentUsers = await User.find()
      .select('name role createdAt')
      .sort({ createdAt: -1 })
      .limit(5);

    const recentActivity = recentUsers.map(u => ({
      action: `${u.role} "${u.name}" registered`,
      time: timeAgo(u.createdAt),
    }));

    res.json({
      totalStudents,
      totalTeachers,
      totalDepartments,
      totalCourses,
      attendance: {
        percentage: 78.5,
        present: 320,
        absent: 60,
        leave: 20,
      },
      recentActivity,
    });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

function timeAgo(date) {
  const diff = Math.floor((Date.now() - new Date(date)) / 1000);
  if (diff < 60) return 'Just now';
  if (diff < 3600) return `${Math.floor(diff / 60)} min ago`;
  if (diff < 86400) return `${Math.floor(diff / 3600)} hrs ago`;
  return `${Math.floor(diff / 86400)} days ago`;
}

module.exports = router;
