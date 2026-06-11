// routes/timetableRoutes.js
const express = require('express');
const router = express.Router();
const timetableController = require('../controllers/timetableController');
const { verifyToken, authorizeRoles } = require('../middleware/authMiddleware');

// Admin provisions schedules; Students and Teachers can read them
router.post('/slots', verifyToken, authorizeRoles('Admin'), timetableController.createSlot);
router.get('/class/:courseId/:semesterNum', verifyToken, authorizeRoles('Admin', 'Student', 'Teacher'), timetableController.getScheduleForClass);

module.exports = router;