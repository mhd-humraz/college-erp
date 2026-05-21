const express = require('express');
const router = express.Router();
const { protect } = require('../middleware/auth');

// All routes require authentication
router.use(protect);

// TEST ROUTE - Dashboard
router.get('/dashboard', async (req, res) => {
  try {
    console.log('🎯 TEACHER DASHBOARD HIT! User:', req.user.email);
    
    res.json({
      success: true,
      data: {
        profile: {
          name: req.user.firstName + ' ' + req.user.lastName,
          email: req.user.email,
          designation: 'Assistant Professor',
          department: 'Computer Science',
          employeeId: 'EMP001',
          isHOD: false
        },
        stats: {
          totalStudents: 150,
          todayClasses: 3,
          thisWeekAttendance: 45,
          pendingMarks: 12,
          totalSubjects: 4
        },
        upcomingClasses: [
          { day: 'Monday', subject: 'Data Structures', course: 'B.Tech CSE - Sem 3', time: '9:00 AM - 10:00 AM', room: 'Room 101' }
        ],
        quickActions: [
          { title: 'Mark Attendance', icon: 'check_circle', route: '/teacher/attendance' },
          { title: 'Enter Marks', icon: 'edit_note', route: '/teacher/marks' }
        ],
        recentActivity: [
          { action: 'Test activity', time: 'Just now', type: 'attendance' }
        ]
      }
    });
  } catch (error) {
    console.error('❌ Dashboard Error:', error.message);
    res.status(500).json({ success: false, message: error.message });
  }
});

// MUST BE LAST LINE!
module.exports = router;