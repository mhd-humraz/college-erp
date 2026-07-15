// backend/routes/adminRoutes.js
const express = require('express');
const router = express.Router();
const multer = require('multer');
const upload = multer({ storage: multer.memoryStorage() }); // Allocation buffers storage matrix configuration
const adminController = require('../controllers/adminController');
const { verifyToken, authorizeRoles } = require('../middleware/authMiddleware');

router.post('/upload-staff', verifyToken, authorizeRoles('Admin'), upload.single('staffFile'), adminController.uploadStaffCSV);
router.get( '/dashboard',  verifyToken, authorizeRoles('Admin'), adminController.getDashboardMetrics );
router.post(  '/departments', verifyToken, authorizeRoles('Admin'),adminController.createDepartment);
router.get( '/departments', verifyToken, authorizeRoles('Admin'),adminController.getDepartments);
router.get('/hello', (req, res) => {
  res.json({ message: 'Admin routes working' });
});
router.post( '/courses',  verifyToken,  authorizeRoles('Admin'), adminController.createCourse);
router.get(  '/courses',  verifyToken, authorizeRoles('Admin'),adminController.getCourses);
router.post(
    '/subjects',
    verifyToken,
    authorizeRoles('Admin'),
    adminController.createSubject
);

router.get(
    '/subjects',
    verifyToken,
    authorizeRoles('Admin'),
    adminController.getSubjects
);
router.post(
    '/faculty',
    verifyToken,
    authorizeRoles('Admin'),
    adminController.createFaculty
);

router.get(
    '/faculty',
    verifyToken,
    authorizeRoles('Admin'),
    adminController.getFaculty
);
router.post(
    '/students',
    verifyToken,
    authorizeRoles('Admin'),
    adminController.createStudent
);

router.get(
    '/students',
    verifyToken,
    authorizeRoles('Admin'),
    adminController.getStudents
);
module.exports = router;