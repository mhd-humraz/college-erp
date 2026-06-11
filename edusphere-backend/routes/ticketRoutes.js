// routes/ticketRoutes.js
const express = require('express');
const router = express.Router();
const ticketController = require('../controllers/ticketController');
const { verifyToken, authorizeRoles } = require('../middleware/authMiddleware');

router.post('/raise', verifyToken, authorizeRoles('Student', 'Teacher'), ticketController.createTicket);
router.get('/list', verifyToken, ticketController.getTickets);
router.patch('/update/:ticketId', verifyToken, authorizeRoles('Admin', 'HOD'), ticketController.updateTicketWorkflow);

module.exports = router;