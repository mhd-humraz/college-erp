// models/Workflows.js
const mongoose = require('mongoose');

const ComplaintSchema = new mongoose.Schema({
    raisedBy: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
    title: { type: String, required: true },
    category: { type: String, enum: ['Infrastructure', 'Academic', 'Hostel', 'Ragging/Harassment'], required: true },
    description: { type: String, required: true },
    status: { type: String, enum: ['Open', 'Assigned', 'In Progress', 'Closed'], default: 'Open' },
    assignedTo: { type: mongoose.Schema.Types.ObjectId, ref: 'User', default: null }
}, { timestamps: true });

const LeaveRequestSchema = new mongoose.Schema({
    student: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
    reason: { type: String, required: true },
    fromDate: { type: Date, required: true },
    toDate: { type: Date, required: true },
    currentApprovalLevel: { type: String, enum: ['Teacher', 'HOD', 'Approved', 'Rejected'], default: 'Teacher' }
}, { timestamps: true });

module.exports = {
    Complaint: mongoose.model('Complaint', ComplaintSchema),
    LeaveRequest: mongoose.model('LeaveRequest', LeaveRequestSchema)
};