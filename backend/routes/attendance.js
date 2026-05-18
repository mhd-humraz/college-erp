const express = require('express');
const router = express.Router();
const Attendance = require('../models/Attendance');
const User = require('../models/User');
const Timetable = require('../models/Timetable');
const auth = require('../middleware/auth');

// GET /api/attendance/today-schedule
router.get('/today-schedule', auth, async (req, res) => {
    try {
        const days = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
        const today = days[new Date().getDay()];
        const todayDate = new Date().toISOString().split('T')[0];
        const slots = await Timetable.find({ day: today, teacherId: req.user.teacherId || req.user.id });
        const enriched = await Promise.all(slots.map(async (slot) => {
            const existing = await Attendance.findOne({ date: todayDate, subject: slot.subject, department: slot.department, semester: slot.semester });
            return { ...slot.toObject(), attendanceTaken: !!existing };
        }));
        res.json({ day: today, slots: enriched });
    } catch (err) { res.status(500).json({ message: err.message }); }
});

// GET /api/attendance/students
router.get('/students', auth, async (req, res) => {
    try {
        const { department, semester } = req.query;
        const students = await User.find({ role: 'Student', department, semester, isActive: true })
            .select('name studentId email guardianPhone department semester');
        res.json(students);
    } catch (err) { res.status(500).json({ message: err.message }); }
});

// POST /api/attendance/save
router.post('/save', auth, async (req, res) => {
    try {
        const { date, subject, department, semester, records } = req.body;
        const existing = await Attendance.findOne({ date, subject, department, semester });
        if (existing) return res.status(400).json({ message: 'Attendance already taken for this class today' });

        const attendance = await Attendance.create({
            date, subject, department, semester,
            teacherId: req.user.id, teacherName: req.user.name, records,
        });

        // Email absent students
        const absentStudents = records.filter(r => r.status === 'Absent');
        const nodemailer = require('nodemailer');
        const transporter = nodemailer.createTransport({
            service: 'gmail',
            auth: { user: process.env.EMAIL_USER, pass: process.env.EMAIL_PASS },
        });

        for (const student of absentStudents) {
            const Notification = require('../models/Notification');
            await Notification.create({
                title: 'Attendance Alert',
                message: `Dear ${student.studentName}, you were marked absent for ${subject} on ${date}.`,
                target: 'Student', sentBy: req.user.name,
            });

            if (student.email) {
                try {
                    await transporter.sendMail({
                        from: `"MESCAS ERP" <${process.env.EMAIL_USER}>`,
                        to: student.email,
                        subject: `Attendance Alert - ${subject}`,
                        html: `
              <div style="font-family:Arial;max-width:500px;margin:auto;padding:24px;background:#222831;border-radius:12px;color:#EEEEEE;">
                <h2 style="color:#00ADB5;">MESCAS ERP — Attendance Alert</h2>
                <p>Dear <strong>${student.studentName}</strong>,</p>
                <p>You were marked <strong style="color:red;">ABSENT</strong> for <strong>${subject}</strong> on <strong>${date}</strong>.</p>
                <p style="color:#aaa;font-size:12px;">Contact your teacher if this is an error.</p>
              </div>
            `,
                    });
                } catch (e) { console.error('Email failed:', e.message); }
            }
        }

        res.json({ message: `Saved. ${absentStudents.length} absent notification(s) sent.`, attendance });
    } catch (err) { res.status(500).json({ message: err.message }); }
});

// GET /api/attendance/overview - for admin monitoring
router.get('/overview', auth, async (req, res) => {
    try {
        const students = await User.find({ role: 'Student', isActive: true }).select('name studentId department semester');
        const result = await Promise.all(students.map(async (s) => {
            const total = await Attendance.countDocuments({ department: s.department, semester: s.semester });
            const present = await Attendance.countDocuments({ department: s.department, semester: s.semester, 'records': { $elemMatch: { studentId: s.studentId, status: 'Present' } } });
            const percentage = total > 0 ? Math.round((present / total) * 100) : 0;
            return { ...s.toObject(), totalClasses: total, presentClasses: present, percentage };
        }));
        const lowAttendance = result.filter(s => s.percentage < 75);
        res.json(lowAttendance);
    } catch (err) { res.status(500).json({ message: err.message }); }
});

module.exports = router;