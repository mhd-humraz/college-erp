// models/Fee.js
const mongoose = require('mongoose');

const TransactionReceiptSchema = new mongoose.Schema({
    transactionId: { type: String, required: true, unique: true },
    amountPaid: { type: Number, required: true },
    paymentMethod: { type: String, enum: ['UPI', 'Card', 'NetBanking', 'Cash'], required: true },
    paidAt: { type: Date, default: Date.now }
}, { _id: false });

const FeeSchema = new mongoose.Schema({
    student: { type: mongoose.Schema.Types.ObjectId, ref: 'Student', required: true },
    academicYear: { type: String, required: true }, // e.g., "2026-2027"
    semester: { type: Number, required: true },
    baseTuitionFee: { type: Number, required: true },
    hostelFee: { type: Number, default: 0 },
    busFee: { type: Number, default: 0 },
    scholarshipApplied: { type: Number, default: 0 }, // Deducted value
    totalDues: { type: Number, required: true }, // Calculated as: base + hostel + bus - scholarship
    amountPaidAccumulated: { type: Number, default: 0 },
    status: { 
        type: String, 
        enum: ['Unpaid', 'Partially_Paid', 'Fully_Paid'], 
        default: 'Unpaid' 
    },
    receipts: [TransactionReceiptSchema]
}, { timestamps: true });

// Optimize query performance for ledger searches and billing audits
FeeSchema.index({ student: 1, status: 1 });

module.exports = mongoose.model('Fee', FeeSchema);