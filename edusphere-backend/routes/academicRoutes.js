// routes/academicRoutes.js
const express = require('express');
const router = express.Router();
const academicController = require('../controllers/academicController');
const { verifyToken, authorizeRoles } = require('../middleware/authMiddleware');

// ==========================================
// 1. ADMINISTRATIVE OPERATION GATEWAYS
// ==========================================
router.post('/departments', verifyToken, authorizeRoles('Admin'), academicController.createDepartment);
router.post('/courses', verifyToken, authorizeRoles('Admin'), academicController.createCourse);
router.post('/subjects', verifyToken, authorizeRoles('Admin'), academicController.createSubject);

// ==========================================
// 2. FACULTY MATRIX HUB ENDPOINTS
// ==========================================

// INTEGRATION UPDATE: This endpoint handles the combined Timetable, Audit, and Push Notification workflows
router.post('/attendance/submit', verifyToken, authorizeRoles('Teacher', 'HOD'), academicController.submitAttendance);

router.post('/marks/submit', verifyToken, authorizeRoles('Teacher', 'HOD'), academicController.submitMarks);

// ==========================================
// 3. STUDENT TELEMETRY INSIGHT HOOKS
// ==========================================
router.get('/student/performance/:studentId', verifyToken, authorizeRoles('Student', 'Parent', 'Teacher'), academicController.getStudentPerformanceSummary);

module.exports = router;