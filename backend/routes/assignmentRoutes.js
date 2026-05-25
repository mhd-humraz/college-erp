const express = require('express');
const router = express.Router();
const auth = require('../middleware/auth');
const roleCheck = require('../middleware/roleCheck');
const assignmentController = require('../controllers/assignmentController');
const multer = require('multer');
const path = require('path');
const fs = require('fs');

// Configure Multer for file uploads
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    const uploadPath = 'uploads/assignments/';
    if (!fs.existsSync(uploadPath)) fs.mkdirSync(uploadPath, { recursive: true });
    cb(null, uploadPath);
  },
  filename: (req, file, cb) => {
    const uniqueName = `${Date.now()}-${Math.round(Math.random() * 1E9)}${path.extname(file.originalname)}`;
    cb(null, uniqueName);
  }
});

const fileFilter = (req, file, cb) => {
  const allowedTypes = ['.pdf', '.doc', '.docx', '.jpg', '.jpeg', '.png', '.zip'];
  const ext = path.extname(file.originalname).toLowerCase();
  if (allowedTypes.includes(ext)) {
    cb(null, true);
  } else {
    cb(new Error('Invalid file type! Allowed: PDF, DOC, Images, ZIP'), false);
  }
};

const upload = multer({ 
  storage, 
  fileFilter, 
  limits: { fileSize: 10 * 1024 * 1024 } // 10MB limit
});

// All routes need auth
router.use(auth);

// ==================== TEACHER ROUTES ====================

// Create new assignment
router.post('/', roleCheck('teacher', 'class_teacher'), assignmentController.createAssignment);

// Upload study material (with file)
router.post('/upload-material', 
  roleCheck('teacher', 'class_teacher'), 
  upload.single('file'),  // ✅ FIXED: Use 'upload' directly instead of 'uploadMiddleware'
  assignmentController.uploadMaterial
);

// Get teacher's assignments
router.get('/my-assignments', roleCheck('teacher', 'class_teacher'), assignmentController.getTeacherAssignments);

// Get submissions for an assignment
router.get('/submissions/:assignmentId', roleCheck('teacher', 'class_teacher'), assignmentController.getSubmissions);

// Grade a submission
router.post('/grade', roleCheck('teacher', 'class_teacher'), assignmentController.gradeSubmission);

// ==================== STUDENT ROUTES ====================

// Submit assignment (with file)
router.post('/submit', 
  roleCheck('student'), 
  upload.single('file'),  // ✅ FIXED: Use 'upload' directly
  assignmentController.submitAssignment
);

// Get student's assignments
router.get('/my', roleCheck('student'), assignmentController.getStudentAssignments);

// ==================== COMMON ROUTES ====================

// Get study materials (all authenticated users)
router.get('/materials', assignmentController.getMaterials);

module.exports = router;