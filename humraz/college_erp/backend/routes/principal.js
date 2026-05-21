const express = require('express');
const router = express.Router();
const User = require('../models/User');
const Student = require('../models/Student');
const Teacher = require('../models/Teacher');
const Department = require('../models/Department');
const Course = require('../models/Course');
const Attendance = require('../models/Attendance');
const MarksEntry = require('../models/Marks');
const Event = require('../models/Event');
const Notification = require('../models/Notification');
const { protect, authorize } = require('../middleware/auth');
const { asyncHandler } = require('../middleware/errorHandler');

// Principal routes
router.use(protect);
router.use(authorize('principal'));

// ============================================
// PRINCIPAL DASHBOARD - INSTITUTIONAL OVERVIEW
// ============================================
router.get('/dashboard', asyncHandler(async (req, res) => {
  // Overall institution statistics
  const stats = await Promise.all([
    User.countDocuments({ role: 'student', isActive: true }),
    User.countDocuments({ role: 'teacher', isActive: true }),
    Department.countDocuments({ isActive: true }),
    Course.countDocuments({ isActive: true }),
    Event.countDocuments({ status: 'upcoming' }),
    Event.countDocuments({ status: 'ongoing' }),
    Attendance.countDocuments({ date: new Date() }),
    Notification.countDocuments({ isActive: true, createdAt: { $gte: new Date(Date.now() - 7*24*60*60*1000) } })
  ]);

  // Department-wise breakdown
  const deptWiseStudents = await Student.aggregate([
    { $match: { isActive: true } },
    { $group: { _id: '$department', count: { $sum: 1 } } },
    { $lookup: { from: 'departments', localField: '_id', foreignField: '_id', as: 'deptInfo' } },
    { $unwind: '$deptInfo' },
    { $project: { departmentName: '$deptInfo.name', count: 1, code: '$deptInfo.code' } },
    { $sort: { count: -1 } }
  ]);

  // Department performance comparison
  const deptPerformance = await Student.aggregate([
    { $match: { isActive: true } },
    { $group: { _id: '$department', avgCGPA: { $avg: '$cgpa' }, totalStudents: { $sum: 1 } } },
    { $lookup: { from: 'departments', localField: '_id', foreignField: '_id', as: 'deptInfo' } },
    { $unwind: '$deptInfo' },
    { $project: { departmentName: '$deptInfo.name', avgCGPA: { $round: ['$avgCGPA', 2] }, totalStudents: 1 } },
    { $sort: { avgCGPA: -1 } }
  ]);

  // Recent events
  const recentEvents = await Event.find()
    .populate('organizer department', 'firstName lastName name')
    .sort({ startDate: 1 })
    .limit(5);

  // Today's attendance overview
  const todayAttendance = await Attendance.aggregate([
    { $match: { date: new Date() } },
    { $group: {
      _id: null,
      totalSessions: { $sum: 1 },
      totalPresent: { $sum: '$presentCount' },
      totalAbsent: { $sum: '$absentCount' },
      avgAttendance: { $avg: { $multiply: [{ $divide: ['$presentCount', '$totalStudents'] }, 100] } }
    }}
  ]);

  // Revenue/Fee collection overview
  const feeOverview = await Student.aggregate([
    { $match: { isActive: true } },
    { $group: {
      _id: '$feeStatus',
      count: { $sum: 1 },
      totalFees: { $sum: '$totalFees' },
      feesPaid: { $sum: '$feesPaid' },
      pendingAmount: { $sum: { $subtract: ['$totalFees', '$feesPaid'] } }
    }}
  ]);

  res.json({
    success: true,
    data: {
      overview: {
        totalStudents: stats[0],
        totalTeachers: stats[1],
        totalDepartments: stats[2],
        totalCourses: stats[3],
        upcomingEvents: stats[4],
        ongoingEvents: stats[5],
        classesToday: stats[6],
        newNotificationsThisWeek: stats[7]
      },
      departmentWiseStudents: deptWiseStudents,
      departmentPerformance: deptPerformance,
      recentEvents,
      todayAttendance: todayAttendance[0] || {},
      feeCollection: feeOverview
    }
  });
}));

// ============================================
// ACADEMIC PERFORMANCE REPORTS
// ============================================
router.get('/reports/academic', asyncHandler(async (req, res) => {
  const { academicYear, semester, department } = req.query;

  const matchStage = {};
  if (semester) matchStage.semester = parseInt(semester);

  // Academic performance metrics
  const academicReport = await MarksEntry.aggregate([
    { $match: matchStage },
    { $group: {
      _id: null,
      totalEntries: { $sum: 1 },
      averageScore: { $round: [{ $avg: '$marks.grandTotal' }, 2] },
      passCount: { $sum: { $cond: [{ $eq: ['$result', 'pass'] }, 1, 0] } },
      failCount: { $sum: { $cond: [{ $eq: ['$result', 'fail'] }, 1, 0] } },
      avgGradePoints: { $round: [{ $avg: '$gradePoints' }, 2] },
      distinctionCount: { $sum: { $cond: [{ $gte: ['$gradePoints', 9] }, 1, 0] } },
      firstClassCount: { $sum: { $cond: [{ $and: [{ $gte: ['$gradePoints', 8] }, { $lt: ['$gradePoints', 9] }] }, 1, 0] } }
    }},
    { $project: {
      _id: 0,
      totalEntries: 1,
      averageScore: 1,
      passRate: { $round: [{ $multiply: [{ $divide: ['$passCount', '$totalEntries'] }, 100] }, 2] },
      failRate: { $round: [{ $multiply: [{ $divide: ['$failCount', '$totalEntries'] }, 100] }, 2] },
      averageGPA: '$avgGradePoints',
      distinctionPercentage: { $round: [{ $multiply: [{ $divide: ['$distinctionCount', '$totalEntries'] }, 100] }, 2] }
    }}
  ]);

  // Grade distribution
  const gradeDistribution = await MarksEntry.aggregate([
    { $match: matchStage },
    { $group: { _id: '$grade', count: { $sum: 1 } } },
    { $sort: { _id: 1 } }
  ]);

  // Top performing students
  const topStudents = await Student.find({ 
    isActive: true,
    ...(department && { department })
  })
    .sort({ cgpa: -1 })
    .limit(20)
    .populate('user', 'firstName lastName')
    .populate('department', 'name')
    .select('rollNumber cgpa semester');

  // Bottom performing students (at-risk)
  const atRiskStudents = await Student.find({
    isActive: true,
    cgpa: { $lt: 5.0 },
    ...(department && { department })
  })
    .sort({ cgpa: 1 })
    .limit(20)
    .populate('user', 'firstName lastName')
    .select('rollNumber cgpa semester');

  // Year-over-year comparison (if data available)
  const yearlyTrend = await Student.aggregate([
    { $group: {
      _id: '$batch',
      avgCGPA: { $avg: '$cgpa' },
      totalStudents: { $sum: 1 }
    }},
    { $sort: { _id: -1 } },
    { $limit: 5 }
  ]);

  res.json({
    success: true,
    data: {
      summary: academicReport[0] || {},
      gradeDistribution,
      topPerformers: topStudents,
      atRiskStudents,
      yearlyTrend,
      generatedAt: new Date()
    }
  });
}));

// ============================================
// FINANCIAL REPORTS
// ============================================
router.get('/reports/financial', asyncHandler(async (req, res) => {
  const { year, month, department } = req.query;

  // Fee collection by status
  const feeStatusBreakdown = await Student.aggregate([
    { $match: { isActive: true, ...(department && { department }) } },
    { $group: {
      _id: '$feeStatus',
      count: { $sum: 1 },
      totalFees: { $sum: '$totalFees' },
      collectedAmount: { $sum: '$feesPaid' },
      pendingAmount: { $sum: { $subtract: ['$totalFees', '$feesPaid'] } }
    }}
  ]);

  // Monthly collection trend (last 12 months)
  const monthlyTrend = await Student.aggregate([
    { $match: { isActive: true } },
    { $group: {
      _id: { $month: '$createdAt' },
      totalFees: { $sum: '$totalFees' },
      collected: { $sum: '$feesPaid' }
    }},
    { $sort: { _id: 1 } }
  ]);

  // Department-wise revenue
  const deptRevenue = await Student.aggregate([
    { $match: { isActive: true } },
    { $group: {
      _id: '$department',
      totalRevenue: { $sum: '$totalFees' },
      collected: { $sum: '$feesPending' },
      pending: { $sum: { $subtract: ['$totalFees', '$feesPaid'] } },
      studentCount: { $sum: 1 }
    }},
    { $lookup: { from: 'departments', localField: '_id', foreignField: '_id', as: 'dept' } },
    { $unwind: '$dept' },
    { $project: { departmentName: '$dept.name', ...('$$ROOT') } },
    { $sort: { totalRevenue: -1 } }
  ]);

  // Fee structure analysis
  const feeAnalysis = await Course.aggregate([
    { $match: { isActive: true } },
    { $group: {
      _id: '$_id',
      courseName: { $first: '$name' },
      avgFee: { $avg: '$feeStructure.totalFee' },
      maxFee: { $max: '$feeStructure.totalFee' },
      minFee: { $min: '$feeStructure.totalFee' },
      enrolledStudents: { $first: '$currentEnrollment' }
    }},
    { $sort: { avgFee: -1 } }
  ]);

  // Financial summary
  const totalRevenue = feeStatusBreakdown.reduce((acc, curr) => acc + (curr.totalFees || 0), 0);
  const totalCollected = feeStatusBreakdown.reduce((acc, curr) => acc + (curr.collectedAmount || 0), 0);
  const totalPending = feeStatusBreakdown.reduce((acc, curr) => acc + (curr.pendingAmount || 0), 0);

  res.json({
    success: true,
    data: {
      summary: {
        totalRevenue,
        totalCollected,
        totalPending,
        collectionRate: totalRevenue > 0 ? ((totalCollected / totalRevenue) * 100).toFixed(2) : 0,
        outstandingAmount: totalPending
      },
      feeStatusBreakdown,
      monthlyTrend,
      departmentWiseRevenue: deptRevenue,
      feeAnalysis,
      currency: 'INR',
      reportGenerated: new Date()
    }
  });
}));

// ============================================
// STAFF/FACULTY REPORTS
// ============================================
router.get('/reports/staff', asyncHandler(async (req, res) => {
  // Staff by department
  const staffByDept = await Teacher.aggregate([
    { $match: { isActive: true } },
    { $group: { _id: '$department', count: { $sum: 1 } } },
    { $lookup: { from: 'departments', localField: '_id', foreignField: '_id', as: 'dept' } },
    { $unwind: '$dept' },
    { $project: { departmentName: '$dept.name', facultyCount: 1 } },
    { $sort: { facultyCount: -1 } }
  ]);

  // Staff by designation
  staffByDesignation = await Teacher.aggregate([
    { $match: { isActive: true } },
    { $group: { _id: '$designation', count: { $sum: 1 } } },
    { $sort: { count: -1 } }
  ]);

  // Staff workload analysis
  const staffWorkload = await Teacher.find({ isActive: true })
    .populate('user', 'firstName lastName email')
    .populate('department', 'name')
    .select('designation totalClassesTaken experience performanceRating leaveBalance')
    .sort({ totalClassesTaken: -1 })
    .limit(30);

  // Experience distribution
  const expDistribution = await Teacher.aggregate([
    { $match: { isActive: true } },
    { $group: {
      _id: {
        $switch: {
          branches: [
            { case: { $lt: ['$experience', 2] }, then: '0-2 years' },
            { case: { $and: [{ $gte: ['$experience', 2] }, { $lt: ['$experience', 5] }] }, then: '2-5 years' },
            { case: { $and: [{ $gte: ['$experience', 5] }, { $lt: ['$experience', 10] }] }, then: '5-10 years' },
            { case: { $gte: ['$experience', 10] }, then: '10+ years' }
          ],
          default: 'Unknown'
        }
      },
      count: { $sum: 1 }
    }},
    { $sort: { _id: 1 } }
  ]);

  // Performance ratings
  const perfRatings = await Teacher.aggregate([
    { $match: { isActive: true } },
    { $group: {
      _id: {
        $switch: {
          branches: [
            { case: { $gte: ['$performanceRating', 4.5] }, then: 'Outstanding' },
            { case: { $and: [{ $gte: ['$performanceRating', 3.5] }, { $lt: ['$performanceRating', 4.5] }] }, then: 'Excellent' },
            { case: { $and: [{ $gte: ['$performanceRating', 2.5] }, { $lt: ['$performanceRating', 3.5] }] }, then: 'Good' },
            { case: { $lt: ['$performanceRating', 2.5] }, then: 'Needs Improvement' }
          ],
          default: 'Not Rated'
        }
      },
      count: { $sum: 1 }
    }}
  ]);

  // Leave utilization
  const leaveUtilization = await Teacher.aggregate([
    { $match: { isActive: true } },
    { $group: {
      _id: null,
      avgCasualLeaveUsed: { $avg: { $subtract: [12, '$leaveBalance.casual'] } },
      avgSickLeaveUsed: { $avg: { $subtract: [10, '$leaveBalance.sick'] } },
      avgEarnedLeaveUsed: { $avg: { $subtract: [15, '$leaveBalance.earned'] } }
    }}
  ]);

  res.json({
    success: true,
    data: {
      byDepartment: staffByDept,
      byDesignation: staffByDesignation,
      staffWorkload,
      experienceDistribution: expDistribution,
      performanceRatings: perfRatings,
      leaveUtilization: leaveUtilization[0] || {}
    }
  });
}));

// ============================================
// EVENTS MANAGEMENT (Principal Level)
// ============================================

// Get all events with detailed info
router.get('/events', asyncHandler(async (req, res) => {
  const { status, type, category } = req.query;
  
  const query = {};
  if (status) query.status = status;
  if (type) query.type = type;
  if (category) query.category = category;

  const events = await Event.find(query)
    .populate('organizer department', 'firstName lastName name')
    .sort({ startDate: -1 });

  // Add participant counts
  const eventsWithCounts = events.map(event => ({
    ...event.toObject(),
    registeredCount: event.participants ? event.participants.length : 0,
    attendedCount: event.participants ? event.participants.filter(p => p.attended).length : 0
  }));

  res.json({ success: true, data: eventsWithCounts });
}));

// Create institutional event
router.post('/events', asyncHandler(async (req, res) => {
  const eventData = {
    ...req.body,
    organizer: req.user.id,
    createdBy: req.user.id,
    isFeatured: true // Principal's events are featured by default
  };

  const event = await Event.create(eventData);

  // Create notification for the event
  await Notification.create({
    title: `🎉 New Event: ${event.title}`,
    message: event.description.substring(0, 100) + '...',
    type: 'event',
    priority: 'high',
    sender: req.user.id,
    senderRole: 'principal',
    targetAudience: 'all',
    actionRequired: false
  });

  res.status(201).json({
    success: true,
    message: 'Event created successfully',
    data: event
  });
}));

// Get event statistics
router.get('/events/statistics', asyncHandler(async (req, res) => {
  const stats = await Promise.all([
    Event.countDocuments({}),
    Event.countDocuments({ status: 'upcoming' }),
    Event.countDocuments({ status: 'ongoing' }),
    Event.countDocuments({ status: 'completed' }),
    Event.countDocuments({ status: 'cancelled' }),
    Event.countDocuments({ registrationOpen: true })
  ]);

  // Events by type
  const eventsByType = await Event.aggregate([
    { $group: { _id: '$type', count: { $sum: 1 } } },
    { $sort: { count: -1 } }
  ]);

  // Most popular events (by registrations)
  const popularEvents = await Event.aggregate([
    { $project: { title: 1, type: 1, startDate: 1, participantCount: { $size: '$participants' } } },
    { $sort: { participantCount: -1 } },
    { $limit: 10 }
  ]);

  res.json({
    success: true,
    data: {
      overview: {
        totalEvents: stats[0],
        upcoming: stats[1],
        ongoing: stats[2],
        completed: stats[3],
        cancelled: stats[4],
        openForRegistration: stats[5]
      },
      byType: eventsByType,
      popularEvents
    }
  });
}));

module.exports = router;