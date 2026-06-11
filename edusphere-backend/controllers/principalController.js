// controllers/principalController.js
const Fee = require('../models/Fee');
const Ticket = require('../models/Ticket');

exports.getCampusExecutiveSummary = async (req, res) => {
    try {
        // 1. Calculate global revenue metrics across all collections
        const financialLedgerSum = await Fee.aggregate([
            {
                $group: {
                    _id: null,
                    projectedRevenue: { $sum: "$totalDues" },
                    collectedRevenue: { $sum: "$amountPaidAccumulated" }
                }
            }
        ]);

        // 2. Count active unresolved campus operational complaints
        const openGrievanceCount = await Ticket.countDocuments({ status: { $ne: 'Closed' } });

        const revenue = financialLedgerSum[0] || { projectedRevenue: 0, collectedRevenue: 0 };

        res.status(200).json({
            success: true,
            summary: {
                totalProjectedRevenue: revenue.projectedRevenue,
                totalCollectedRevenue: revenue.collectedRevenue,
                outstandingDues: revenue.projectedRevenue - revenue.collectedRevenue,
                activeGrievances: openGrievanceCount
            }
        });
    } catch (err) { res.status(500).json({ error: err.message }); }
};