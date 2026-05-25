const express = require('express');
const router = express.Router();
const auth = require('../middleware/auth');
const roleCheck = require('../middleware/roleCheck');
const {
  getDashboard,
  getMyTimetable,
  getMyAttendance,
  getMarks,
  getNotifications,
  applyLeave,
  requestAddStudent,
  getClassStudents
} = require('../controllers/studentController');

router.use(auth);
router.use(roleCheck('student', 'class_teacher')); // Class teachers can also use some endpoints

router.get('/dashboard', getDashboard);
router.get('/timetable', getMyTimetable);
router.get('/attendance', getMyAttendance);
router.get('/marks', getMarks);
router.get('/notifications', getNotifications);
router.post('/apply-leave', applyLeave);
router.post('/request-student', roleCheck('class_teacher'), requestAddStudent);
router.get('/class-students', roleCheck('class_teacher'), getClassStudents);

module.exports = router;