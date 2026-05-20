const express = require('express');
const router = express.Router();
const auth = require('../middleware/auth');
const User = require('../models/User');
const Leave = require('../models/Leave');
const Attendance = require('../models/Attendance');

// GET /api/dashboard/hod
router.get('/hod', auth, async (req, res) => {
  try {
    // Only HODs or Admins can access this specific dashboard data
    if (req.user.role !== 'HOD' && req.user.role !== 'Admin') {
      return res.status(403).json({ success: false, message: 'Forbidden' });
    }

    const user = await User.findById(req.user.id);
    const department = user.department;

    // 1. Stats
    const totalStudents = await User.countDocuments({ role: 'Student', department });
    const totalFaculty = await User.countDocuments({ role: 'Teacher', department });
    
    // 2. Pending Approvals (Teacher leaves awaiting HOD)
    const pendingApprovals = await Leave.find({ 
      approverRole: 'HOD', 
      status: 'Pending', 
      department 
    }).populate('applicant', 'name teacherId');

    // 3. Faculty Monitoring (Example: list of teachers in dept)
    const facultyMonitoring = await User.find({ role: 'Teacher', department })
                                        .select('name teacherId designation');

    // 4. Attendance Overview (Students with low attendance - placeholder logic)
    const attendanceOverview = await Attendance.aggregate([
      { $unwind: "$records" },
      { $group: { 
          _id: "$records.student", 
          totalClasses: { $sum: 1 }, 
          presentClasses: { $sum: { $cond: [{ $eq: ["$records.status", "Present"] }, 1, 0] } }
        }
      },
      { $project: { 
          studentId: "$_id", 
          percentage: { $multiply: [{ $divide: ["$presentClasses", "$totalClasses"] }, 100] } 
        }
      },
      { $match: { percentage: { $lt: 75 } } }, // Less than 75%
      { $limit: 5 }
    ]);

    res.json({
      success: true,
      data: {
        stats: { totalStudents, totalFaculty },
        attendanceOverview,
        facultyMonitoring,
        pendingApprovals
      }
    });

  } catch (error) {
    res.status(500).json({ success: false, message: 'Server error', error: error.message });
  }
});

module.exports = router;