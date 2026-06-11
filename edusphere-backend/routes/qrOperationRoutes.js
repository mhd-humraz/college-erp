// routes/qrOperationRoutes.js
const express = require('express');
const router = express.Router();
const qrOperationController = require('../controllers/qrOperationController');
const { verifyToken, authorizeRoles } = require('../middleware/authMiddleware');

router.post('/scan-library-issue', verifyToken, authorizeRoles('Library Staff', 'Admin'), qrOperationController.processLibraryQrIssue);
router.post('/scan-event-attendance', verifyToken, authorizeRoles('Teacher', 'Admin'), qrOperationController.processEventQrAttendance);

module.exports = router;