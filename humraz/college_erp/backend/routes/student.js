const express = require('express');
const router = express.Router();
const Student = require('../models/Student');
const Attendance = require('../models/Attendance');
const MarksEntry = require('../models/Marks');
const Assignment = require('../models/Assignment');
const TimetableEntry = require('../models/Timetable');
const Notification = require('../models/Notification');
const BookTransaction = require('../models/BookTransaction');
const { protect, authorize } = require('../middleware/auth');
const { calculateAttendancePercentage, getPagination, getPagingData } = require('../utils/helpers');

router.use(protect);
router.use(authorize('student'));

router.get('/dashboard', async (req, res) => {
  const student = await Student.findOne({ user: req.user.id }).populate('department course');
  if (!student) return res.status(404).json({ success: false, message: 'Student profile not found' });

  const attendanceStats = await Attendance.aggregate([
    { $match: { 'records.student': student._id } },
    { $unwind: '$records' },
    { $match: { 'records.student': student._id } },
    { $group: { _id: null, totalClasses: { $sum: 1 }, presentCount: { $sum: { $cond: [{ $eq: ['$records.status', 'present'] }, 1, 0] } } } }
  ]);

  const attendancePercentage = attendanceStats.length > 0 ? calculateAttendancePercentage(attendanceStats[0].presentCount, attendanceStats[0].totalClasses) : 0;
  const pendingAssignments = await Assignment.countDocuments({ course: student.course, semester: student.semester, section: student.section, status: 'active', 'submissions.student': { $ne: student._id } });
  const activeBooks = await BookTransaction.countDocuments({ student: student._id, status: 'active' });

  res.json({ success: true, data: { student, statistics: { attendancePercentage, pendingAssignments, activeLibraryBooks: activeBooks } } });
});

router.get('/profile', async (req, res) => {
  const student = await Student.findOne({ user: req.user.id }).populate('department course user');
  res.json({ success: true, data: student });
});

router.get('/attendance', async (req, res) => {
  const student = await Student.findOne({ user: req.user.id });
  const attendances = await Attendance.find({ 'records.student': student._id }).populate('subject teacher').sort({ date: -1 });
  res.json({ success: true, data: attendances });
});

router.get('/marks', async (req, res) => {
  const student = await Student.findOne({ user: req.user.id });
  const marks = await MarksEntry.find({ student: student._id, isPublished: true }).populate('subject exam').sort({ createdAt: -1 });
  res.json({ success: true, data: marks });
});

router.get('/assignments', async (req, res) => {
  const student = await Student.findOne({ user: req.user.id });
  const assignments = await Assignment.find({ course: student.course, semester: student.semester, section: student.section }).populate('subject teacher').sort({ dueDate: 1 });
  res.json({ success: true, data: assignments });
});

router.get('/timetable', async (req, res) => {
  const student = await Student.findOne({ user: req.user.id });
  const timetable = await TimetableEntry.find({ course: student.course, semester: student.semester, section: student.section, isActive: true }).populate('subject teacher').sort({ day: 1, period: 1 });
  res.json({ success: true, data: timetable });
});

router.get('/notifications', async (req, res) => {
  const notifications = await Notification.find({ isActive: true }).sort({ createdAt: -1 }).limit(20);
  res.json({ success: true, data: notifications });
});

module.exports = router;