const express = require('express');
const router = express.Router();
const auth = require('../middleware/auth');
const roleCheck = require('../middleware/roleCheck');
const upload = require('../middleware/upload');
const {
  uploadStudentsCSV,
  getDepartmentStudents,
  assignTeacher,
  createTimetable,
  getTimetable,
  getRequests,
  addStudentManually,
  // ✅ NEW: Add these controller functions
  getTeachers,
  getClasses,
  getSubjects,
  updateRequestStatus,
  createSubject  // ✅ ADD THIS LINE!
} = require('../controllers/hodController');

// All routes need authentication & HOD role
router.use(auth);
router.use(roleCheck('hod'));

// ==================== STUDENT MANAGEMENT ====================
router.post('/upload-students-csv', upload.single('file'), uploadStudentsCSV);
router.get('/students', getDepartmentStudents);
router.post('/add-student-manual', addStudentManually);

// ==================== TEACHER MANAGEMENT ====================
router.get('/teachers', getTeachers);
router.post('/assign-teacher', assignTeacher);

// ==================== CLASS & SUBJECT MANAGEMENT ====================
router.get('/classes', getClasses);
router.get('/subjects', getSubjects);
router.post('/create-subject', createSubject);  // ✅ FIXED: Just use createSubject (not hodController.createSubject)

// ==================== TIMETABLE MANAGEMENT ====================
router.post('/timetable', createTimetable);
router.get('/timetable/:classId?', getTimetable);

// ==================== REQUEST MANAGEMENT ====================
router.get('/requests', getRequests);
router.put('/requests/:requestId', updateRequestStatus);

module.exports = router;