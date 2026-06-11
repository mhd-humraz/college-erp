// controllers/aiController.js
const Attendance = require('../models/Attendance');
const Student = require('../models/Student');
const AiAuditLog = require('../models/AiAuditLog');

exports.processAiQuery = async (req, res) => {
    try {
        const { query } = req.body;
        const role = req.user.role;
        let dataPayload = null;
        let determinedIntent = "Unknown";
        let conversationalAnswer = "I understand your query, but I couldn't map it to an authorized database pipeline.";

        const lowercaseQuery = query.toLowerCase();

        // 1. INTENT TRACK: FACULTY AUDITING AT-RISK STUDENTS (< 75%)
        if (lowercaseQuery.includes('attendance') && ['Teacher', 'Admin', 'HOD'].includes(role)) {
            determinedIntent = "Faculty_Low_Attendance_Audit";
            
            dataPayload = await Attendance.aggregate([
                { $unwind: "$records" },
                { 
                    $group: { 
                        _id: "$records.student", 
                        total: { $sum: 1 }, 
                        present: { $sum: { $cond: ["$records.isPresent", 1, 0] } } 
                    } 
                },
                { $project: { percentage: { $multiply: [ { $divide: ["$present", "$total"] }, 100 ] } } },
                { $match: { percentage: { $lt: 75 } } }
            ]);
            
            conversationalAnswer = `System scan complete. I identified ${dataPayload.length} students falling below the required 75% attendance threshold flag.`;
        } 
        
        // 2. INTENT TRACK: STUDENT TRACKING SELF ATTENDANCE TRENDS
        else if (lowercaseQuery.includes('my attendance') && role === 'Student') {
            determinedIntent = "Student_Self_Attendance_Audit";
            
            const studentProfile = await Student.findOne({ user: req.user.id });
            if (studentProfile) {
                const logs = await Attendance.find({ "records.student": studentProfile._id });
                let totalClasses = logs.length;
                let presentCount = 0;
                
                logs.forEach(log => {
                    const match = log.records.find(r => r.student.toString() === studentProfile._id.toString());
                    if (match && match.isPresent) presentCount++;
                });

                const percentage = totalClasses > 0 ? ((presentCount / totalClasses) * 100).toFixed(2) : "100.00";
                dataPayload = { percentage, totalClasses, presentCount };
                conversationalAnswer = `Your verified attendance balance is currently at ${percentage}%. You have attended ${presentCount} out of ${totalClasses} total lecture slots logged this semester.`;
            }
        }

        // Save transactional metrics log record for audit trails
        await AiAuditLog.create({
            user: req.user.id,
            userRole: role,
            rawQuery: query,
            resolvedIntent: determinedIntent,
            executionSuccess: true
        });

        res.json({
            success: true,
            intent: determinedIntent,
            insights: dataPayload,
            conversationalResponse: conversationalAnswer
        });

    } catch (err) {
        res.status(500).json({ error: err.message });
    }
};