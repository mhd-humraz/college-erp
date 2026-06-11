// routes/aiV2Routes.js
const express = require('express');
const router = express.Router();
const aiV2Controller = require('../controllers/aiV2Controller');
const { verifyToken, authorizeRoles } = require('../middleware/authMiddleware');

// 🚀 LOCALHOST TESTING ROUTE: Skips security guards so you can check your seed data instantly
router.get('/test-predictive-risk/:studentId', aiV2Controller.analyzeAndPredictStudentRisk);

// Secure production routes
router.get('/predictive-risk/:studentId', verifyToken, authorizeRoles('Teacher', 'HOD', 'Admin', 'Student'), aiV2Controller.analyzeAndPredictStudentRisk);

module.exports = router;