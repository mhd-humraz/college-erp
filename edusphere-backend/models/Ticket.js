// models/Ticket.js
const mongoose = require('mongoose');

const TicketCommentSchema = new mongoose.Schema({
    author: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
    message: { type: String, required: true, trim: true }
}, { timestamps: true });

const TicketSchema = new mongoose.Schema({
    raisedBy: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
    title: { type: String, required: true, trim: true },
    category: { type: String, enum: ['Infrastructure', 'Academic', 'Hostel', 'Administrative'], required: true },
    description: { type: String, required: true },
    status: { 
        type: String, 
        enum: ['Open', 'Assigned', 'In Progress', 'Resolved', 'Closed'], 
        default: 'Open' 
    },
    assignedTo: { type: mongoose.Schema.Types.ObjectId, ref: 'User', default: null },
    comments: [TicketCommentSchema]
}, { timestamps: true });

module.exports = mongoose.model('Ticket', TicketSchema);