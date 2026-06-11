// routes/aiRoutes.js
const express = require('express');
const router = express.Router();
const aiController = require('../controllers/aiController');
const { verifyToken } = require('../middleware/authMiddleware');

router.post('/ask-intelligence', verifyToken, aiController.processAiQuery);

module.exports = router;