const express = require('express');
const router = express.Router();
const auth = require('../middleware/auth');
const roleCheck = require('../middleware/roleCheck');
const auditController = require('../controllers/auditController');

router.use(auth);
router.use(roleCheck('admin', 'hod'));

router.get('/', auditController.getAuditLogs);

module.exports = router;