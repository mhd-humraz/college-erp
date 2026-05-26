const User = require('../models/User');
const Attendance = require('../models/Attendance');
const Mark = require('../models/Mark');
const Department = require('../models/Department');
const Class = require('../models/Class');
const AuditLog = require('../models/AuditLog');

// @desc   Get Dashboard Analytics for Admin
exports.getAdminAnalytics = async (req, res) => {
  try {
    const [
      totalUsers,
      totalDepartments,
      totalStudents,
      totalTeachers,
      recentLogs,
      departmentStats,
      attendanceStats,
      lowAttendanceStudents
    ] = await Promise.all([
      User.countDocuments({ isActive: true }),
      Department.countDocuments(),
      User.countDocuments({ role: 'student', isActive: true }),
      User.countDocuments({ role: { $in: ['teacher', 'class_teacher'] }, isActive: true }),
      AuditLog.find().sort({ createdAt: -1 }).limit(10).populate('userId', 'name'),
      Department.find().populate('hodId', 'name'),
      _getAttendanceOverview(),
      _getLowAttendanceStudents()
    ]);

    res.json({
      success: true,
      data: {
        overview: {
          totalUsers,
          totalDepartments,
          totalStudents,
          totalTeachers
        },
        recentActivity: recentLogs,
        departmentStats,
        attendanceStats,
        alerts: {
          lowAttendanceCount: lowAttendanceStudents.length,
          students: lowAttendanceStudents.slice(0, 10)
        }
      }
    });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

// @desc   Get HOD Department Analytics
exports.getHODAnalytics = async (req, res) => {
  try {
    const deptId = req.user.departmentId;

    const [
      deptStudents,
      deptTeachers,
      classesInDept,
      attendanceBySubject,
      monthlyAttendance,
      topPerformers,
      weakStudents
    ] = await Promise.all([
      User.countDocuments({ departmentId: deptId, role: 'student', isActive: true }),
      User.countDocuments({ departmentId: deptId, role: { $in: ['teacher', 'class_teacher'] }, isActive: true }),
      Class.countDocuments({ departmentId: deptId }),
      _getAttendanceByDepartment(deptId),
      _getMonthlyAttendance(deptId),
      _getTopPerformers(deptId),
      _getWeakStudents(deptId)
    ]);

    res.json({
      success: true,
      data: {
        overview: {
          students: deptStudents,
          teachers: deptTeachers,
          classes: classesInDept
        },
        attendanceBySubject,
        monthlyAttendance,
        topPerformers,
        weakStudents
      }
    });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

// @desc   Get Student Personal Analytics
exports.getStudentAnalytics = async (req, res) => {
  try {
    const studentId = req.user._id;

    const [attendanceRecords, marks, overallAttendance] = await Promise.all([
      Attendance.find({ studentId }).sort({ date: -1 }).limit(60),
      Mark.find({ studentId }).populate('subjectId', 'name code'),
      _calculateOverallAttendance(studentId)
    ]);

    // Group by month
    const monthlyData = _groupAttendanceByMonth(attendanceRecords);
    
    // Subject-wise performance
    const subjectPerformance = _calculateSubjectPerformance(marks);

    // Attendance trend (last 30 days)
    const trendData = _generateTrendData(attendanceRecords);

    // Alerts
    const alerts = [];
    if (overallAttendance < 75) {
      alerts.push({
        type: 'danger',
        message: `Your attendance is ${overallAttendance.toFixed(1)}%. Below 75% threshold!`,
        icon: 'warning'
      });
    } else if (overallAttendance < 85) {
      alerts.push({
        type: 'warning',
        message: `Your attendance is ${overallAttendance.toFixed(1)}%. Keep it up!`,
        icon: 'info'
      });
    }

    res.json({
      success: true,
      data: {
        overallAttendance,
        monthlyData,
        subjectPerformance,
        trendData,
        alerts,
        totalAssignments: marks.length,
        averageScore: marks.length > 0 
          ? (marks.reduce((sum, m) => sum + (m.score / m.maxScore * 100), 0) / marks.length).toFixed(1)
          : 0
      }
    });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

// Helper Functions
async function _getAttendanceOverview() {
  const result = await Attendance.aggregate([
    { $group: { _id: '$status', count: { $sum: 1 } } }
  ]);
  
  const total = result.reduce((sum, r) => sum + r.count, 0);
  const present = result.find(r => r._id === 'present')?.count || 0;
  
  return {
    total,
    present,
    absent: result.find(r => r._id === 'absent')?.count || 0,
    late: result.find(r => r._id === 'late')?.count || 0,
    percentage: total > 0 ? ((present / total) * 100).toFixed(1) : 0
  };
}

async function _getLowAttendanceStudents() {
  const results = await Attendance.aggregate([
    { $match: { status: { $in: ['present', 'absent'] } } },
    { $group: { 
      _id: '$studentId',
      present: { $sum: { $cond: [{ $eq: ['$status', 'present'] }, 1, 0] } },
      total: { $sum: 1 }
    }},
    { $addFields: { percentage: { $multiply: [{ $divide: ['$present', '$total'] }, 100] } } },
    { $match: { percentage: { $lt: 75 } } },
    { $sort: { percentage: 1 } },
    { $limit: 20 },
    { $lookup: { from: 'users', localField: '_id', foreignField: '_id', as: 'student' } },
    { $unwind: '$student' },
    { $project: { studentName: '$student.name', rollNumber: '$student.rollNumber', percentage: 1 }}
  ]);
  
  return results;
}

async function _getAttendanceByDepartment(deptId) {
  const users = await User.find({ departmentId: deptId, role: 'student' }).distinct('_id');
  const records = await Attendance.find({ studentId: { $in: users } });
  
  const present = records.filter(r => r.status === 'present').length;
  const total = records.length;
  
  return { present, total, percentage: total > 0 ? ((present / total) * 100).toFixed(1) : 0 };
}

async function _getMonthlyAttendance(deptId) {
  const users = await User.find({ departmentId: deptId, role: 'student' }).distinct('_id');
  
  const result = await Attendance.aggregate([
    { $match: { studentId: { $in: users } } },
    { $group: {
      _id: { $dateToString: { format: '%Y-%m', date: '$date' } },
      present: { $sum: { $cond: [{ $eq: ['$status', 'present'] }, 1, 0] } },
      total: { $sum: 1 }
    }},
    { $sort: { _id: 1 } },
    { $limit: 6 }
  ]);
  
  return result.map(r => ({
    month: r._id,
    present: r.present,
    total: r.total,
    percentage: r.total > 0 ? ((r.present / r.total) * 100).toFixed(1) : 0
  }));
}

async function _getTopPerformers(deptId) {
  const results = await Mark.aggregate([
    { $lookup: { from: 'users', localField: 'studentId', foreignField: '_id', as: 'student' }},
    { $unwind: '$student' },
    { $match: { 'student.departmentId': deptId }},
    { $group: {
      _id: '$studentId',
      name: { $first: '$student.name' },
      avgScore: { $avg: { $multiply: [{ $divide: ['$score', '$maxScore'] }, 100] }}
    }},
    { $sort: { avgScore: -1 } },
    { $limit: 5 }
  ]);
  
  return results;
}

async function _getWeakStudents(deptId) {
  const results = await Mark.aggregate([
    { $lookup: { from: 'users', localField: 'studentId', foreignField: '_id', as: 'student' }},
    { $unwind: '$student' },
    { $match: { 'student.departmentId': deptId }},
    { $group: {
      _id: '$studentId',
      name: { $first: '$student.name' },
      avgScore: { $avg: { $multiply: [{ $divide: ['$score', '$maxScore'] }, 100] }}
    }},
    { $sort: { avgScore: 1 } },
    { $limit: 5 }
  ]);
  
  return results.filter(r => r.avgScore < 50);
}

async function _calculateOverallAttendance(studentId) {
  const records = await Attendance.find({ studentId });
  if (records.length === 0) return 100;
  
  const present = records.filter(r => r.status === 'present').length;
  return ((present / records.length) * 100);
}

function _groupAttendanceByMonth(records) {
  const grouped = {};
  records.forEach(r => {
    const month = new Date(r.date).toLocaleString('default', { month: 'short' });
    if (!grouped[month]) grouped[month] = { present: 0, absent: 0, total: 0 };
    grouped[month].total++;
    if (r.status === 'present') grouped[month].present++;
    else grouped[month].absent++;
  });
  return Object.entries(grouped).map(([month, data]) => ({ month, ...data }));
}

function _calculateSubjectPerformance(marks) {
  const grouped = {};
  marks.forEach(m => {
    const subjId = m.subjectId?._id?.toString();
    if (!subjId) return;
    if (!grouped[subjId]) {
      grouped[subjId] = { subjectName: m.subjectId?.name || 'Unknown', scores: [] };
    }
    grouped[subjId].scores.push((m.score / m.maxScore) * 100);
  });
  
  return Object.values(grouped).map(g => ({
    ...g,
    average: g.scores.reduce((a, b) => a + b, 0) / g.scores.length
  }));
}

function _generateTrendData(records) {
  const last30 = records.slice(0, 30).reverse();
  return last30.map((r, i) => ({
    day: i + 1,
    status: r.status === 'present' ? 1 : 0,
    date: r.date
  }));
}