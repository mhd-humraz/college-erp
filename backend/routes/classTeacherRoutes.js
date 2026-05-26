const express = require('express');
const router = express.Router();
const auth = require('../middleware/auth');
const roleCheck = require('../middleware/roleCheck');

const {
  getMyStudents,
  markAttendance,
  requestStudent,
  getLeaveRequests,
  updateLeaveStatus
} = require('../controllers/classTeacherController');

router.use(auth);
router.use(roleCheck('class_teacher'));

// Student Management
router.get('/students', getMyStudents);

// Attendance
router.post('/mark-attendance', markAttendance);

// Request Student (to HOD)
router.post('/request-student', requestStudent);

// Leave Management
router.get('/leave-requests', getLeaveRequests);
router.put('/leave-requests/:leaveId', updateLeaveStatus);

module.exports = router;