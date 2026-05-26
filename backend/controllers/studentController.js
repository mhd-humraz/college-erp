const User = require('../models/User');
const Timetable = require('../models/Timetable');
const Attendance = require('../models/Attendance');
const Mark = require('../models/Mark');
const Notification = require('../models/Notification');
const LeaveRequest = require('../models/LeaveRequest');

// @desc   Get Student Dashboard Data
exports.getDashboard = async (req, res) => {
  try {
    const studentId = req.user._id;
    const classId = req.user.classId;

    // Get attendance stats
    const totalClasses = await Attendance.countDocuments({ studentId });
    const presentDays = await Attendance.countDocuments({ studentId, status: 'present' });
    const attendancePercent = totalClasses > 0 ? ((presentDays / totalClasses) * 100).toFixed(1) : 0;

    // Get recent marks
    const recentMarks = await Mark.find({ studentId })
      .populate('subjectId', 'name code')
      .sort({ createdAt: -1 })
      .limit(5);

    // Get unread notifications count
    const unreadNotifications = await Notification.countDocuments({
      $or: [
        { targetRole: 'student', targetClassId: classId },
        { targetRole: 'all' },
        { targetDepartmentId: req.user.departmentId }
      ],
      isRead: false
    });

    res.json({
      success: true,
      data: {
        attendancePercentage: parseFloat(attendancePercent),
        totalClasses,
        presentDays,
        recentMarks,
        unreadNotifications
      }
    });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

// @desc   Get Student Timetable
exports.getMyTimetable = async (req, res) => {
  try {
    const timetable = await Timetable.find({ classId: req.user.classId })
      .populate('subjectId', 'name code type')
      .populate('teacherId', 'name')
      .sort({ day: 1, period: 1 });

    const grouped = {};
    timetable.forEach(entry => {
      if (!grouped[entry.day]) grouped[entry.day] = [];
      grouped[entry.day].push(entry);
    });

    res.json({ success: true, data: grouped });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

// @desc   Get My Attendance
exports.getMyAttendance = async (req, res) => {
  try {
    const attendance = await Attendance.find({ studentId: req.user._id })
      .populate('subjectId', 'name code')
      .sort({ date: -1 })
      .limit(50);

    // Calculate per-subject percentage
    const subjectStats = {};
    attendance.forEach(att => {
      const subId = att.subjectId?._id?.toString();
      if (subId) {
        if (!subjectStats[subId]) {
          subjectStats[subId] = { subject: att.subjectId, total: 0, present: 0 };
        }
        subjectStats[subId].total++;
        if (att.status === 'present') subjectStats[subId].present++;
      }
    });

    Object.keys(subjectStats).forEach(key => {
      const stat = subjectStats[key];
      stat.percentage = stat.total > 0 ? ((stat.present / stat.total) * 100).toFixed(1) : 0;
    });

    res.json({ 
      success: true, 
      data: { 
        records: attendance,
        subjectWise: Object.values(subjectStats)
      } 
    });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

// @desc   Get My Marks
exports.getMarks = async (req, res) => {
  try {
    const marks = await Mark.find({ studentId: req.user._id })
      .populate('subjectId', 'name code credits')
      .sort({ createdAt: -1 });

    // Group by exam type
    const grouped = {};
    marks.forEach(mark => {
      if (!grouped[mark.examType]) grouped[mark.examType] = [];
      grouped[mark.examType].push(mark);
    });

    res.json({ success: true, data: grouped });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

// @desc   Get Notifications
exports.getNotifications = async (req, res) => {
  try {
    const notifications = await Notification.find({
      $or: [
        { targetRole: 'student', targetClassId: req.user.classId },
        { targetRole: 'all' },
        { targetRole: 'student', targetDepartmentId: req.user.departmentId }
      ]
    })
      .populate('senderId', 'name role')
      .sort({ createdAt: -1 })
      .limit(30);

    res.json({ success: true, count: notifications.length, data: notifications });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

// @desc   Apply Leave
exports.applyLeave = async (req, res) => {
  try {
    const { reason, fromDate, toDate } = req.body;

    const leave = await LeaveRequest.create({
      studentId: req.user._id,
      reason,
      fromDate: new Date(fromDate),
      toDate: new Date(toDate),
      status: 'pending'
    });

    res.status(201).json({ success: true, data: leave, message: 'Leave application submitted' });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

// @desc   Request Missing Student (For Class Teachers)
exports.requestAddStudent = async (req, res) => {
  try {
    const { studentName, rollNumber, reason } = req.body;

    const request = await Request.create({
      type: 'add_student',
      studentName,
      rollNumber,
      classId: req.user.classId,
      requestedBy: req.user._id,
      reason,
      status: 'pending'
    });

    res.status(201).json({ 
      success: true, 
      data: request, 
      message: 'Request sent to HOD for approval' 
    });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

// @desc   Get Class Students (For Class Teacher)
exports.getClassStudents = async (req, res) => {
  try {
    const students = await User.find({ 
      classId: req.user.classId, 
      role: 'student',
      isActive: true 
    })
      .select('name rollNumber email phone _id')
      .sort({ name: 1 });

    res.json({ success: true, count: students.length, data: students });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};