const express = require('express');
const router = express.Router();
const auth = require('../middleware/auth');
const roleCheck = require('../middleware/roleCheck');
const {
  getMyClasses,
  getStudentsByClass,
  markAttendance,
  uploadMarks,
  getMyTimetable
} = require('../controllers/teacherController');

router.use(auth);
router.use(roleCheck('teacher', 'class_teacher'));

router.get('/my-classes', getMyClasses);
router.get('/students/:classId', getStudentsByClass);
router.post('/mark-attendance', markAttendance);
router.post('/upload-marks', uploadMarks);
router.get('/my-timetable', getMyTimetable);

module.exports = router;