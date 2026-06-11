// routes/feeRoutes.js
const express = require('express');
const router = express.Router();
const feeController = require('../controllers/feeController');
const { verifyToken, authorizeRoles } = require('../middleware/authMiddleware');

router.post('/invoice/create', verifyToken, authorizeRoles('Admin'), feeController.generateInvoice);
router.post('/pay', verifyToken, authorizeRoles('Student', 'Admin'), feeController.collectPayment);
router.get('/student/:studentId', verifyToken, feeController.getStudentDues);

module.exports = router;