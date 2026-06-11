// backend/routes/hodRoutes.js
const express = require('express');
const router = express.Router();
const multer = require('multer');
const upload = multer({ storage: multer.memoryStorage() });
const hodController = require('../controllers/hodController');
const { verifyToken, authorizeRoles } = require('../middleware/authMiddleware');

router.post('/upload-students', verifyToken, authorizeRoles('HOD'), upload.single('studentFile'), hodController.uploadDepartmentStudentsCSV);

module.exports = router;