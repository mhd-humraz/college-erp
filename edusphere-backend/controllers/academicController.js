// controllers/academicController.js
const Department = require('../models/Department');
const Course = require('../models/Course');
const Subject = require('../models/Subject');
const Student = require('../models/Student');
const Attendance = require('../models/Attendance');
const Marks = require('../models/Marks');

// ==========================================
// 1. ADMINISTRATIVE INFRASTRUCTURE MANAGERS
// ==========================================

exports.createDepartment = async (req, res) => {
    try {
        const { name, code } = req.body;
        const dept = await Department.create({ name, code });
        res.status(201).json({ success: true, data: dept });
    } catch (err) { res.status(400).json({ error: err.message }); }
};

exports.createCourse = async (req, res) => {
    try {
        const { name, departmentId, totalSemesters } = req.body;
        const course = await Course.create({ name, department: departmentId, totalSemesters });
        res.status(201).json({ success: true, data: course });
    } catch (err) { res.status(400).json({ error: err.message }); }
};

exports.createSubject = async (req, res) => {
    try {
        const { name, code, courseId, semester } = req.body;
        const subject = await Subject.create({ name, code, course: courseId, semester });
        res.status(201).json({ success: true, data: subject });
    } catch (err) { res.status(400).json({ error: err.message }); }
};

// ==========================================
// 2. TEACHER OPERATION MANAGERS
// ==========================================

exports.submitAttendance = async (req, res) => {
    try {
        const { subjectId, facultyId, hour, date, records } = req.body; 
        // Expected record format structure payload: [{ student: "STUDENT_ID", isPresent: true }]
        
        const log = await Attendance.create({
            subject: subjectId,
            faculty: facultyId,
            date,
            hour,
            records
        });

        // Broadcast live real-time notification confirmation via socket framework
        req.io.emit('attendance_updated', { subjectId, date });

        res.status(201).json({ success: true, message: "Attendance ledger committed successfully", data: log });
    } catch (err) { res.status(500).json({ error: err.message }); }
};

exports.submitMarks = async (req, res) => {
    try {
        const { subjectId, examType, maxMarks, scores } = req.body;
        // Expected scores payload structural array format: [{ student: "STUDENT_ID", marksObtained: 85 }]

        const gradeSheet = await Marks.create({ subject: subjectId, examType, maxMarks, scores });
        res.status(201).json({ success: true, message: "Grade ledger committed successfully", data: gradeSheet });
    } catch (err) { res.status(500).json({ error: err.message }); }
};

// ==========================================
// 3. STUDENT INSIGHT ENGINE
// ==========================================

exports.getStudentPerformanceSummary = async (req, res) => {
    try {
        const { studentId } = req.params;

        // Fetch attendance logs where student matches array sub-document field criteria
        const attendanceLogs = await Attendance.find({ "records.student": studentId }).populate('subject', 'name code');
        
        // Compute metrics baseline calculations safely
        let totalClasses = attendanceLogs.length;
        let presentCount = 0;
        
        attendanceLogs.forEach(log => {
            const match = log.records.find(r => r.student.toString() === studentId);
            if (match && match.isPresent) presentCount++;
        });

        const marksLogs = await Marks.find({ "scores.student": studentId }).populate('subject', 'name code');

        res.status(200).json({
            attendance: {
                totalSlots: totalClasses,
                presentSlots: presentCount,
                percentage: totalClasses > 0 ? ((presentCount / totalClasses) * 100).toFixed(2) : "100.00"
            },
            grades: marksLogs
        });
    } catch (err) { res.status(500).json({ error: err.message }); }
};
// Add this import statement to the top of your academicController.js file:
const AcademicAggregator = require('../services/academicAggregator');

// Replace your old submitAttendance method with this integrated one:
exports.submitAttendance = async (req, res) => {
    try {
        // Hands off the payload to our central integration engine
        const operationalLog = await AcademicAggregator.verifyAndRecordAttendance(req, req.body);
        
        res.status(201).json({ 
            success: true, 
            message: "Attendance ledger committed successfully, constraints verified, alerts sent.", 
            data: operationalLog 
        });
    } catch (err) { 
        res.status(400).json({ error: err.message }); 
    }
};