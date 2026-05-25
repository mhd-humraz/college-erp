const express = require('express');
const router = express.Router();
const auth = require('../middleware/auth');
const roleCheck = require('../middleware/roleCheck');
const analyticsController = require('../controllers/analyticsController');

router.use(auth);

router.get('/admin', roleCheck('admin'), analyticsController.getAdminAnalytics);
router.get('/hod', roleCheck('hod'), analyticsController.getHODAnalytics);
router.get('/student', roleCheck('student'), analyticsController.getStudentAnalytics);

module.exports = router;