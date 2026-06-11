// controllers/ticketController.js
const Ticket = require('../models/Ticket');

// 1. CREATE NEW COMPLAINT TICKET
exports.createTicket = async (req, res) => {
    try {
        const { title, category, description } = req.body;
        const newTicket = await Ticket.create({
            raisedBy: req.user.id, // Extracted securely from your Week 3 JWT verification middleware
            title,
            category,
            description
        });

        // Push real-time broadcast notification out to the Admin Socket channel
        req.io.emit('new_ticket_alert', newTicket);

        res.status(201).json({ success: true, data: newTicket });
    } catch (err) { res.status(500).json({ error: err.message }); }
};

// 2. READ LOGS FOR CURRENT USER OR ALL (ADMINS)
exports.getTickets = async (req, res) => {
    try {
        let query = {};
        // If the user isn't an Admin, filter the query to only return their own tickets
        if (req.user.role !== 'Admin') {
            query.raisedBy = req.user.id;
        }

        const history = await Ticket.find(query)
            .populate('raisedBy', 'email')
            .sort({ createdAt: -1 });

        res.status(200).json({ success: true, data: history });
    } catch (err) { res.status(500).json({ error: err.message }); }
};

// 3. MUTATE TICKET WORKFLOW STATE OR APPEND COMMENTS
exports.updateTicketWorkflow = async (req, res) => {
    try {
        const { ticketId } = req.params;
        const { status, assignedTo, commentMessage } = req.body;

        const ticket = await Ticket.findById(ticketId);
        if (!ticket) return res.status(404).json({ error: "Ticket index parameter not found" });

        if (status) ticket.status = status;
        if (assignedTo) ticket.assignedTo = assignedTo;
        
        if (commentMessage) {
            ticket.comments.push({
                author: req.user.id,
                message: commentMessage
            });
        }

        await ticket.save();
        
        // Notify the student that their ticket has been updated
        req.io.emit(`ticket_updated_${ticket.raisedBy}`, ticket);

        res.status(200).json({ success: true, data: ticket });
    } catch (err) { res.status(500).json({ error: err.message }); }
};