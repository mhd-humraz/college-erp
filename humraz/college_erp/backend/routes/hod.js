const express = require('express');
const router = express.Router();
const Teacher = require('../models/Teacher');
const Student = require('../models/Student');
const Department = require('../models/Department');
const Attendance = require('../models/Attendance');
const MarksEntry = require('../models/Marks');
const TimetableEntry = require('../models/Timetable');
const Assignment = require('../models/Assignment');
const { protect, authorize } = require('../middleware/auth');
const { asyncHandler } = require('../middleware/errorHandler');

// All HOD routes
router.use(protect);
router.use(authorize('hod'));

// ============================================
// HOD DASHBOARD
// ============================================
router.get('/dashboard', asyncHandler(async (req, res) => {
  const teacher = await Teacher.findOne({ user: req.user.id }).populate('department');
  
  if (!teacher || !teacher.isHOD) {
    return res.status(403).json({
      success: false,
      message: 'Not authorized as HOD'
    });
  }

  const departmentId = teacher.department._id;

  // Department statistics
  const stats = await Promise.all([
    Student.countDocuments({ department: departmentId, isActive: true }),
    Teacher.countDocuments({ department: departmentId, isActive: true }),
    Attendance.countDocuments({ department: departmentId }),
    MarksEntry.countDocuments({ department: departmentId }),
    Assignment.countDocuments({ department: departmentId, status: 'active' })
  ]);

  // Faculty list with performance
  const facultyList = await Teacher.find({ department: departmentId, isActive: true })
    .populate('user', 'firstName lastName email avatar')
    .select('designation experience performanceRating totalClassesTaken leaveBalance')
    .sort('employeeId');

  // Average attendance by subject/semester
  const attendanceBySemester = await Attendance.aggregate([
    { $match: { department: departmentId } },
    { $group: {
      _id: '$semester',
      avgPresent: { $avg: '$presentCount' },
      avgTotal: { $avg: '$totalStudents' },
      totalSessions: { $sum: 1 }
    }},
    { $sort: { _id: 1 } }
  ]);

  // Recent activity
  const recentAttendance = await Attendance.find({ department: departmentId })
    .populate('subject teacher')
    .sort({ createdAt: -1 })
    .limit(5);

  res.json({
    success: true,
    data: {
      department: teacher.department,
      statistics: {
        totalStudents: stats[0],
        totalFaculty: stats[1],
        totalAttendanceSessions: stats[2],
        totalMarksEntries: stats[3],
        activeAssignments: stats[4]
      },
      facultyList,
      attendanceBySemester,
      recentActivity: recentAttendance
    }
  });
}));

// ============================================
// FACULTY MANAGEMENT
// ============================================

// GET all faculty in department
router.get('/faculty', asyncHandler(async (req, res) => {
  const teacher = await Teacher.findOne({ user: req.user.id });
  
  const faculty = await Teacher.find({ department: teacher.department, isActive: true })
    .populate('user', 'firstName lastName email phone avatar')
    .populate('subjects')
    .populate('classes.course')
    .sort('employeeId');

  // Add additional computed fields
  const facultyWithStats = await Promise.all(
    faculty.map(async (f) => {
      const classesToday = await TimetableEntry.countDetails({
        teacher: f._id,
        day: new Date().toLocaleLowerCase('en-US', { weekday: 'long' }),
        isActive: true
      });
      
      const pendingAssignments = await Assignment.countDocuments({
        teacher: f._id,
        status: 'active'
      });

      return {
        ...f.toObject(),
        classesToday,
        pendingAssignments,
        workload: `${f.totalClassesTaken} classes`
      };
    })
  );

  res.json({ success: true, data: facultyWithStats });
}));

// GET single faculty details
router.get('/faculty/:id', asyncHandler(async (req, res) => {
  const faculty = await Teacher.findById(req.params.id)
    .populate('user', '-password')
    .populate('department')
    .populate('subjects')
    .populate('classes.course');

  if (!faculty) {
    return res.status(404).json({
      success: false,
      message: 'Faculty member not found'
    });
  }

  // Get faculty's recent activities
  const recentAttendance = await Attendance.find({ teacher: faculty._id })
    .populate('subject')
    .sort({ createdAt: -1 })
    .limit(10);

  const upcomingClasses = await TimetableEntry.find({
    teacher: faculty._id,
    isActive: true
  })
    .populate('subject course section')
    .sort({ day: 1, period: 1 });

  res.json({
    success: true,
    data: {
      faculty,
      recentAttendance,
      upcomingClasses
    }
  });
}));

// Update faculty info (limited fields for HOD)
router.put('/faculty/:id', asyncHandler(async (req, res) => {
  const { designation, specialization, subjects } = req.body;
  
  const updateData = {};
  if (designation) updateData.designation = designation;
  if (specialization) updateData.specialization = specialization;
  if (subjects) updateData.subjects = subjects;

  const faculty = await Teacher.findByIdAndUpdate(
    req.params.id,
    updateData,
    { new: true, runValidators: true }
  ).populate('user', 'firstName lastName');

  if (!faculty) {
    return res.status(404).json({
      success: false,
      message: 'Faculty member not found'
    });
  }

  res.json({
    success: true,
    message: 'Faculty information updated',
    data: faculty
  });
}));

// ============================================
// STUDENT PERFORMANCE MONITORING
// ============================================

// GET student performance analytics
router.get('/students/performance', asyncHandler(async (req, res) => {
  const teacher = await Teacher.findOne({ user: req.user.id });
  const { semester, sortBy = 'cgpa', order = 'desc', minCGPA, maxCGPA } = req.query;

  const query = { 
    department: teacher.department, 
    isActive: true 
  };
  
  if (semester) query.semester = parseInt(semester);
  if (minCGPA || maxCGPA) {
    query.cgpa = {};
    if (minCGPA) query.cgpa.$gte = parseFloat(minCGPA);
    if (maxCGPA) query.cgpa.$lte = parseFloat(maxCGPA);
  }

  const sortObj = {};
  sortObj[sortBy] = order === 'asc' ? 1 : -1;

  const students = await Student.find(query)
    .populate('user', 'firstName lastName email rollNumber')
    .populate('course')
    .sort(sortObj)
    .limit(100); // Top/bottom 100 students

  // Performance distribution
  const performanceDist = await Student.aggregate([
    { $match: { department: teacher.department } },
    { $group: {
      _id: null,
      avgCGPA: { $avg: '$cgpa' },
      totalStudents: { $sum: 1 },
      above9: { $sum: { $cond: [{ $gte: ['$cgpa', 9] }, 1, 0] } },
      above8: { $sum: { $cond: [{ $gte: ['$cgpa', 8] }, 1, 0] } },
      above7: { $sum: { $cond: [{ $gte: ['$cgpa', 7] }, 1, 0] } },
      below7: { $sum: { $cond: [{ $lt: ['$cgpa', 7] }, 1, 0] } },
      distinction: { $sum: { $cond: [{ $gte: ['$cgpa', 8.5] }, 1, 0] } },
      firstClass: { $sum: { $cond: [{ $and: [{ $gte: ['$cgpa', 6] }, { $lt: ['$cgpa', 8.5] }] }, 1, 0] } },
      secondClass: { $sum: { $cond: [{ $and: [{ $gte: ['$cgpa', 5] }, { $lt: ['$cgpa', 6] }] }, 1, 0] } },
      fail: { $sum: { $cond: [{ $lt: ['$cgpa', 5] }, 1, 0] } }
    }}
  ]);

  // Subject-wise average performance
  const subjectPerformance = await MarksEntry.aggregate([
    { $match: { department: teacher.department } },
    { $group: {
      _id: '$subject',
      avgGrandTotal: { $avg: '$marks.grandTotal' },
      avgGradePoints: { $avg: '$gradePoints' },
      passRate: {
        $multiply: [
          { $divide: [
            { $sum: { $cond: [{ $eq: ['$result', 'pass'] }, 1, 0] } },
            { $sum: 1 }
          ]},
          100
        ]
      },
      totalEntries: { $sum: 1 }
    }},
    { $lookup: { from: 'subjects', localField: '_id', foreignField: '_id', as: 'subjectInfo' } },
    { $unwind: '$subjectInfo' },
    { $sort: { avgGradePoints: -1 } }
  ]);

  res.json({
    success: true,
    data: {
      topPerformers: students.slice(0, 10),
      allStudents: students,
      performanceDistribution: performanceDist[0] || {},
      subjectWisePerformance: subjectPerformance
    }
  });
}));

// GET at-risk students (low attendance or CGPA)
router.get('/students/at-risk', asyncHandler(async (req, res) => {
  const teacher = await Teacher.findOne({ user: req.user.id });
  
  // Students with low CGPA (< 5.0)
  const lowCGPA = await Student.find({
    department: teacher.department,
    cgpa: { $lt: 5.0 },
    isActive: true
  }).populate('user', 'firstName lastName rollNumber')
    .sort({ cgpa: 1 })
    .limit(20);

  // Students with low attendance (would need to calculate from attendance records)
  // For now, returning students who might be at risk based on other factors
  const irregularStudents = await Student.aggregate([
    { $match: { department: teacher.department } },
    { $lookup: { from: 'attendances', localField: '_id', foreignField: 'records.student', as: 'attendance' } },
    { $addFields: { attendanceCount: { $size: '$attendance' } } },
    { $sort: { attendanceCount: 1 } },
    { $limit: 20 }
  ]);

  res.json({
    success: true,
    data: {
      lowCGPA,
      lowAttendance: irregularStudents,
      recommendations: [
        'Schedule counseling sessions for at-risk students',
        'Arrange remedial classes for weak subjects',
        'Notify parents about attendance issues',
        'Provide additional study materials'
      ]
    }
  });
}));

// ============================================
// ATTENDANCE REPORTS
// ============================================

// GET department attendance reports
router.get('/attendance/reports', asyncHandler(async (req, res) => {
  const teacher = await Teacher.findOne({ user: req.user.id });
  const { startDate, endDate, semester, section, subject } = req.query;

  const query = { department: teacher.department };
  
  if (startDate && endDate) {
    query.date = { $gte: new Date(startDate), $lte: new Date(endDate) };
  }
  if (semester) query.semester = parseInt(semester);
  if (section) query.section = section;
  if (subject) query.subject = subject;

  const reports = await Attendance.find(query)
    .populate('subject teacher')
    .sort({ date: -1 });

  // Calculate overall statistics
  const overallStats = await Attendance.aggregate([
    { $match: { department: teacher.department } },
    { $group: {
      _id: null,
      totalSessions: { $sum: 1 },
      avgPresentPercent: {
        $avg: { $multiply: [{ $divide: ['$presentCount', '$totalStudents'] }, 100] }
      },
      totalPresent: { $sum: '$presentCount' },
      totalAbsent: { $sum: '$absentCount' }
    }}
  ]);

  // Day-wise attendance trend
  const dayWiseTrend = await Attendance.aggregate([
    { $match: { department: teacher.department } },
    { $group: {
      _id: { $dayOfWeek: '$date' },
      totalClasses: { $sum: 1 },
      avgAttendance: { $avg: { $multiply: [{ $divide: ['$presentCount', '$totalStudents'] }, 100] } }
    }},
    { $sort: { _id: 1 } }
  ]);

  // Subject-wise attendance
  const subjectWise = await Attendance.aggregate([
    { $match: { department: teacher.department } },
    { $group: {
      _id: '$subject',
      totalSessions: { $sum: 1 },
      avgPresent: { $avg: '$presentCount' },
      avgAbsent: { $avg: '$absentCount' }
    }},
    { $lookup: { from: 'subjects', localField: '_id', foreignField: '_id', as: 'subjectInfo' } },
    { $unwind: '$subjectInfo' },
    { $sort: { avgPresent: -1 } }
  ]);

  res.json({
    success: true,
    data: {
      reports,
      overallStatistics: overallStats[0] || {},
      dayWiseTrend,
      subjectWiseAttendance: subjectWise
    }
  });
}));

// GET class-wise attendance summary
router.get('/attendance/class-summary', asyncHandler(async (req, res) => {
  const teacher = await Teacher.findOne({ user: req.user.id });
  const { semester, section } = req.query;

  const matchStage = { department: teacher.department };
  if (semester) matchStage.semester = parseInt(semester);
  if (section) matchStage.section = section;

  const classSummary = await Attendance.aggregate([
    { $match: matchStage },
    { $group: {
      _id: { semester: '$semester', section: '$section' },
      totalSessions: { $sum: 1 },
      avgPresentPercent: {
        $avg: { $multiply: [{ $divide: ['$presentCount', '$totalStudents'] }, 100] }
      },
      lastClassDate: { $max: '$date' }
    }},
    { $sort: { '_id.semester': 1, '_id.section': 1 } }
  ]);

  res.json({ success: true, data: classSummary });
}));

// ============================================
// TIMETABLE APPROVALS
// ============================================

// GET pending timetable approvals
router.get('/timetable/pending', asyncHandler(async (req, res) => {
  const teacher = await Teacher.findOne({ user: req.user.id });
  
  const pendingTimetables = await TimetableEntry.find({
    department: teacher.department,
    approvalStatus: 'pending'
  })
    .populate('subject teacher course')
    .sort({ createdAt: 1 });

  res.json({ success: true, data: pendingTimetables });
}));

// Approve/reject timetable entry
router.put('/timetable/:id/status', asyncHandler(async (req, res) => {
  const { action, remarks } = req.body; // action: 'approve' or 'reject'
  
  const timetable = await TimetableEntry.findById(req.params.id);

  if (!timetable) {
    return res.status(404).json({
      success: false,
      message: 'Timetable entry not found'
    });
  }

  timetable.approvalStatus = action === 'approve' ? 'approved' : 'rejected';
  timetable.approvedBy = req.user.id;
  timetable.isActive = action === 'approve';
  
  if (remarks) timetable.remarks = remarks;
  
  await timetable.save();

  res.json({
    success: true,
    message: `Timetable ${action}d successfully`,
    data: timetable
  });
}));

// Batch approve multiple timetables
router.post('/timetable/batch-approve', asyncHandler(async (req, res) => {
  const { ids, action } = req.body; // Array of timetable IDs

  const result = await TimetableEntry.updateMany(
    { _id: { $in: ids }, approvalStatus: 'pending' },
    {
      approvalStatus: action === 'approve' ? 'approved' : 'rejected',
      approvedBy: req.user.id,
      isActive: action === 'approve'
    }
  );

  res.json({
    success: true,
    message: `${result.modifiedCount} timetable entries ${action}d`,
    modifiedCount: result.modifiedCount
  });
}));

// ============================================
// ACADEMIC MONITORING
// ============================================

// GET department academic overview
router.get('/academic/overview', asyncHandler(async (req, res) => {
  const teacher = await Teacher.findOne({ user: req.user.id });

  // Semester-wise student distribution
  const semesterDistribution = await Student.aggregate([
    { $match: { department: teacher.department, isActive: true } },
    { $group: { _id: '$semester', count: { $sum: 1 } } },
    { $sort: { _id: 1 } }
  ]);

  // Section-wise distribution
  const sectionDistribution = await Student.aggregate([
    { $match: { department: teacher.department, isActive: true } },
    { $group: { _id: '$section', count: { $sum: 1 } } },
    { $sort: { _id: 1 } }
  ]);

  // CGPA distribution across semesters
  const cgpaBySemester = await Student.aggregate([
    { $match: { department: teacher.department, isActive: true } },
    { $group: {
      _id: '$semester',
      avgCGPA: { $avg: '$cgpa' },
      maxCGPA: { $max: '$cgpa' },
      minCGPA: { $min: '$cgpa' },
      count: { $sum: 1 }
    }},
    { $sort: { _id: 1 } }
  ]);

  // Recent marks entries
  const recentMarks = await MarksEntry.find({ department: teacher.department })
    .populate('student', 'rollNumber')
    .populate('subject', 'name code')
    .sort({ createdAt: -1 })
    .limit(20);

  res.json({
    success: true,
    data: {
      semesterDistribution,
      sectionDistribution,
      cgpaBySemester,
      recentMarks
    }
  });
}));

// GET faculty workload analysis
router.get('/faculty/workload', asyncHandler(async (req, res) => {
  const teacher = await Teacher.findOne({ user: req.user.id });

  const facultyWorkload = await Teacher.find({
    department: teacher.department,
    isActive: true
  })
    .populate('user', 'firstName lastName')
    .select('totalClassesTaken designation experience performanceRating leaveBalance')
    .sort({ totalClassesTaken: -1 });

  // Workload statistics
  const workloadStats = await Teacher.aggregate([
    { $match: { department: teacher.department, isActive: true } },
    { $group: {
      _id: null,
      avgClasses: { $avg: '$totalClassesTaken' },
      maxClasses: { $max: '$totalClassesTaken' },
      minClasses: { $min: '$totalClassesTaken' },
      totalFaculty: { $sum: 1 },
      avgExperience: { $avg: '$experience' },
      avgPerformance: { $avg: '$performanceRating' }
    }}
  ]);

  res.json({
    success: true,
    data: {
      facultyWorkload,
      statistics: workloadStats[0] || {}
    }
  });
}));

module.exports = router;