// routes/portfolioRoutes.js
const express = require('express');
const router = express.Router();
const portfolioController = require('../controllers/portfolioController');
const { verifyToken, authorizeRoles } = require('../middleware/authMiddleware');

router.post('/add', verifyToken, authorizeRoles('Student'), portfolioController.addAchievement);
router.get('/summary/:studentId', verifyToken, portfolioController.getPortfolioSummary);

module.exports = router;