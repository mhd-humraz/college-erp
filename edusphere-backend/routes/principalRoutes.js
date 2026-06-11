const express = require('express');
const router = express.Router();
const principalController = require('../controllers/principalController');
const { verifyToken, authorizeRoles } = require('../middleware/authMiddleware');

router.get('/executive-summary', verifyToken, authorizeRoles('Principal', 'Admin'), principalController.getCampusExecutiveSummary);

module.exports = router;