// routes/operationRoutes.js
const express = require('express');
const router = express.Router();
const { verifyToken, authorizeRoles } = require('../../middleware/authMiddleware');
const { Book, BookTransaction, EventRegistration } = require('../../models/Operations');
const { Complaint } = require('../../models/Workflows');

// ==========================================
// LIBRARY MANAGED TRANSACTIONS VIA QR PATTERNS
// ==========================================
router.post('/library/issue', verifyToken, authorizeRoles('Library Staff', 'Admin'), async (req, res) => {
    try {
        const { bookId, studentId } = req.body; // Scanned directly from target user's profile token QR code
        const book = await Book.findById(bookId);
        
        if (!book || book.availableCopies < 1) {
            return res.status(400).json({ error: "Target resource inventory fully depleted" });
        }

        book.availableCopies -= 1;
        await book.save();

        const transaction = new BookTransaction({
            book: bookId,
            student: studentId,
            dueDate: new Date(Date.now() + 14 * 24 * 60 * 60 * 1000) // 14-day limit policy
        });
        await transaction.save();

        res.status(201).json({ success: true, message: "Asset transaction linked successfully" });
    } catch (err) { res.status(500).json({ error: err.message }); }
});

// ==========================================
// REAL-TIME COMPLAINT INTERFACES WITH SOCKET PIPES
// ==========================================
router.post('/complaints', verifyToken, authorizeRoles('Student', 'Teacher'), async (req, res) => {
    try {
        const ticket = new Complaint({ ...req.body, raisedBy: req.user._id });
        await ticket.save();

        // Broadcast notification update across real-time sockets to administrators
        req.io.emit('new_complaint_ticket', ticket);

        res.status(201).json({ success: true, data: ticket });
    } catch (err) { res.status(500).json({ error: err.message }); }
});

module.exports = router;