const User = require('../models/User');
const Class = require('../models/Class');
const Attendance = require('../models/Attendance');
const LeaveRequest = require('../models/LeaveRequest');
const Request = require('../models/Request');

// Get Class Teacher's assigned students
exports.getMyStudents = async (req, res) => {
  try {
    const classDoc = await Class.findOne({ classTeacherId: req.user._id }).populate('departmentId', 'name');
    
    if (!classDoc) {
      return res.json({ success: true, data: [], message: 'No class assigned yet' });
    }

    const students = await User.find({ 
      classId: classDoc._id, 
      role: 'student',
      isActive: true 
    })
      .select('-password')
      .populate('classId', 'name')
      .sort({ name: 1 });

    // Calculate attendance percentage for each student
    const studentsWithStats = await Promise.all(students.map(async (student) => {
      const totalAttendance = await Attendance.countDocuments({
        studentId: student._id,
        status: { $in: ['present', 'late'] }
      });
      
      const totalClasses = await Attendance.countDocuments({
        studentId: student._id
      });

      const attendancePercent = totalClasses > 0 
        ? ((totalAttendance / totalClasses) * 100).toFixed(1)
        : 'N/A';

      return {
        ...student.toObject(),
        attendancePercent: attendancePercent,
        className: classDoc.name
      };
    }));

    res.json({ success: true, count: studentsWithStats.length, data: studentsWithStats });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

// Mark Attendance for entire class
exports.markAttendance = async (req, res) => {
  try {
    const { records } = req.body;

    if (!records || records.length === 0) {
      return res.status(400).json({ success: false, message: 'No attendance records provided' });
    }

    const attendanceDocs = records.map(record => ({
      ...record,
      classTeacherId: req.user._id,
      date: new Date()
    }));

    await Attendance.insertMany(attendanceDocs);

    res.json({ 
      success: true, 
      message: `Attendance marked for ${records.length} students`,
      count: records.length 
    });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

// Request to add missing student (creates request for HOD)
exports.requestStudent = async (req, res) => {
  try {
    const { studentName, rollNumber, reason } = req.body;

    if (!studentName || !rollNumber) {
      return res.status(400).json({ success: false, message: 'Student name and roll number are required' });
    }

    // Check if student already exists
    const existingStudent = await User.findOne({ rollNumber, role: 'student' });
    if (existingStudent) {
      return res.status(400).json({ success: false, message: 'Student already exists in system' });
    }

    // Create request for HOD
    const request = await Request.create({
      type: 'add_student',
      requestedBy: req.user._id,
      requestData: { studentName, rollNumber },
      reason: reason || 'Missing from class roster',
      departmentId: req.user.departmentId,
      status: 'pending'
    });

    res.status(201).json({ 
      success: true, 
      message: 'Request submitted to HOD successfully',
      data: request 
    });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

// Get Leave Requests for Class Teacher's students
exports.getLeaveRequests = async (req, res) => {
  try {
    // Get class teacher's class
    const classDoc = await Class.findOne({ classTeacherId: req.user._id });
    
    if (!classDoc) {
      return res.json({ success: true, data: [] });
    }

    // Get students in this class
    const studentIds = await User.find({ 
      classId: classDoc._id, 
      role: 'student' 
    }).distinct('_id');

    // Get leave requests for these students
    const leaves = await LeaveRequest.find({
      studentId: { $in: studentIds }
    })
      .populate('studentId', 'name email rollNumber')
      .sort({ createdAt: -1 });

    res.json({ success: true, count: leaves.length, data: leaves });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

// Update Leave Status (Approve/Reject)
exports.updateLeaveStatus = async (req, res) => {
  try {
    const { leaveId } = req.params;
    const { status } = req.body;

    if (!['approved', 'rejected'].includes(status)) {
      return res.status(400).json({ success: false, message: 'Invalid status' });
    }

    const leave = await LeaveRequest.findByIdAndUpdate(
      leaveId,
      { 
        status,
        reviewedBy: req.user._id,
        reviewedAt: new Date()
      },
      { new: true }
    ).populate('studentId', 'name');

    if (!leave) {
      return res.status(404).json({ success: false, message: 'Leave request not found' });
    }

    res.json({ 
      success: true, 
      message: `Leave ${status}`,
      data: leave 
    });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};