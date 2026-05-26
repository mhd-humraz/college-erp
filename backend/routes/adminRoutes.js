const express = require('express');
const router = express.Router();
const auth = require('../middleware/auth');
const roleCheck = require('../middleware/roleCheck');
const upload = require('../middleware/upload');
const {
  createDepartment,
  getDepartments,
  assignHOD,
  uploadStaffCSV,
  getAllUsers
} = require('../controllers/adminController');

// All admin routes require authentication AND admin role
router.use(auth);
router.use(roleCheck('admin'));

router.post('/departments', createDepartment);
router.get('/departments', getDepartments);
router.post('/assign-hod', assignHOD);
router.post('/upload-staff-csv', upload.single('file'), uploadStaffCSV);
router.get('/users', getAllUsers);

module.exports = router;