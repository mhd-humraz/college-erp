// controllers/feeController.js
const Fee = require('../models/Fee');
const AuditLogger = require('../services/auditLogger');
const NotificationEngine = require('../services/notificationEngine');

// 1. GENERATE BASE INVOICE BILLING RECORD (Admin Action)
exports.generateInvoice = async (req, res) => {
    try {
        const { studentId, academicYear, semester, baseTuitionFee, hostelFee, busFee, scholarshipApplied } = req.body;

        const totalDues = (baseTuitionFee + (hostelFee || 0) + (busFee || 0)) - (scholarshipApplied || 0);

        const invoice = await Fee.create({
            student: studentId,
            academicYear,
            semester,
            baseTuitionFee,
            hostelFee,
            busFee,
            scholarshipApplied,
            totalDues
        });

        // Trigger real-time notifications to the student
        await NotificationEngine.dispatchMultiCastNotification({
            recipients: [studentId],
            title: "New Semester Invoice Generated",
            body: `Your fee statement for Semester ${semester} is ready. Total due: ₹${totalDues}.`,
            category: "Finance"
        });

        res.status(201).json({ success: true, data: invoice });
    } catch (err) { res.status(500).json({ error: err.message }); }
};

// 2. PROCESS INCOMING PAYMENT (Student/Cashier Action)
exports.collectPayment = async (req, res) => {
    try {
        const { feeId, transactionId, amountPaid, paymentMethod } = req.body;

        const feeRecord = await Fee.findById(feeId);
        if (!feeRecord) return res.status(404).json({ error: "Invoice index not found." });

        // Update balances
        feeRecord.amountPaidAccumulated += amountPaid;
        feeRecord.receipts.push({ transactionId, amountPaid, paymentMethod });

        if (feeRecord.amountPaidAccumulated >= feeRecord.totalDues) {
            feeRecord.status = 'Fully_Paid';
        } else {
            feeRecord.status = 'Partially_Paid';
        }

        await feeRecord.save();

        // Log the transaction to the audit logs
        await AuditLogger.logAction({
            user: req.user.id,
            role: req.user.role,
            action: 'COLLECT_FEE_PAYMENT',
            target: `Fee ID: ${feeId} | Amount: ₹${amountPaid}`,
            status: 'Success'
        });

        res.status(200).json({ success: true, message: "Payment processed successfully.", record: feeRecord });
    } catch (err) { res.status(500).json({ error: err.message }); }
};

// 3. READ LEDGER BALANCES (Student Self Inspection)
exports.getStudentDues = async (req, res) => {
    try {
        const duesHistory = await Fee.find({ student: req.params.studentId }).sort({ createdAt: -1 });
        res.status(200).json({ success: true, data: duesHistory });
    } catch (err) { res.status(500).json({ error: err.message }); }
};