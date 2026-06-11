// controllers/aiV2Controller.js
const Student = require('../models/Student');
const Attendance = require('../models/Attendance');
const Fee = require('../models/Fee');
const AiInsight = require('../models/AiInsight');

exports.analyzeAndPredictStudentRisk = async (req, res) => {
    try {
        const { studentId } = req.params;

        // 1. COMPUTE DETAILED HISTORICAL ATTENDANCE ATTRIBUTES
        const totalAttendanceLogs = await Attendance.find({ "records.student": studentId });
        
        if (totalAttendanceLogs.length === 0) {
            return res.status(200).json({ success: true, message: "Insufficient analytical baseline data to run predictions." });
        }

        let totalSlots = totalAttendanceLogs.length;
        let attendedSlots = 0;

        // Trace specific index structures inside records array matrix
        totalAttendanceLogs.forEach(log => {
            const currentRecord = log.records.find(r => r.student.toString() === studentId);
            if (currentRecord && currentRecord.isPresent) attendedSlots++;
        });

        const currentAttendanceRate = (attendedSlots / totalSlots) * 100;

        // 2. RUN ATTENDANCE FORECAST ALGORITHM
        // Simulates an historical degradation curve (e.g., assuming students skip more classes near finals)
        let predictedSemesterEndAttendance = currentAttendanceRate * 0.94; 
        if (predictedSemesterEndAttendance > 100) predictedSemesterEndAttendance = 100;

        // 3. SECURE REVENUE & INVOICE RISK INPUTS
        const unpaidInvoices = await Fee.countDocuments({ student: studentId, status: 'Unpaid' });
        const hasPendingFees = unpaidInvoices > 0;

        // 4. MOCK CRUNCH ACADEMIC MARKS INDEX FOR TARGET EVALUATION (Baseline 72/100)
        const academicPerformanceScore = 72; 

        // 5. EVALUATE THRESHOLDS TO DETERMINISTIC RISK RATINGSMATRIX
        let riskLevel = 'Low';
        let recommendationText = 'Student performance trails within expected university guidelines. Maintain current study patterns.';

        if (predictedSemesterEndAttendance < 75 || academicPerformanceScore < 50) {
            riskLevel = 'High';
            recommendationText = 'CRITICAL ALERT: Student predicted to fall short of the mandatory 75% final semester attendance requirement. Immediate intervention required.';
        } else if (predictedSemesterEndAttendance < 80 || hasPendingFees) {
            riskLevel = 'Medium';
            recommendationText = 'WARNING: Minor anomalies detected. Attendance trends are decaying, or outstanding financial invoices are open.';
        }

        // 6. UPSERT PREDICTIVE PROFILE METRICS INTO MONGO
        const dynamicInsightProfile = await AiInsight.findOneAndUpdate(
            { student: studentId },
            {
                currentAttendanceRate: currentAttendanceRate.toFixed(2),
                predictedSemesterEndAttendance: predictedSemesterEndAttendance.toFixed(2),
                academicPerformanceScore,
                hasPendingFees,
                riskLevel,
                recommendationText
            },
            { upsert: true, new: true }
        );

        res.status(200).json({
            success: true,
            message: "Predictive Analytics Forecast Engine generation execution complete.",
            analytics: dynamicInsightProfile
        });

    } catch (err) {
        res.status(500).json({ error: err.message });
    }
};