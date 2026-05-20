const express = require('express');
const router = express.Router();
const auth = require('../middleware/auth');
const Leave = require('../models/Leave');
const User = require('../models/User');

// ──────────────────────────────────────────────
// POST /api/leave/apply
// Student applies -> goes to Teacher
// Teacher applies -> goes to HOD
// ──────────────────────────────────────────────
router.post('/apply', auth, async (req, res) => {
  try {
    const { fromDate, toDate, reason } = req.body;
    const user = await User.findById(req.user.id);

    if (!user) return res.status(404).json({ message: 'User not found' });

    let approverRole = '';
    let department = user.department;
    let semester = user.semester || null;

    // Determine who approves based on who is applying
    if (user.role === 'Student') {
      approverRole = 'Teacher';
    } else if (user.role === 'Teacher') {
      approverRole = 'HOD';
    } else {
      return res.status(400).json({ message: 'Invalid role for leave application' });
    }

    const newLeave = new Leave({
      applicant: user._id,
      applicantRole: user.role,
      approverRole: approverRole,
      department: department,
      semester: semester,
      fromDate: fromDate,
      toDate: toDate,
      reason: reason,
      status: 'Pending'
    });

    await newLeave.save();
    
    res.status(201).json({ 
      message: `Leave applied successfully. Awaiting ${approverRole} approval.`, 
      data: newLeave 
    });

  } catch (error) {
    res.status(500).json({ message: 'Server error', error: error.message });
  }
});

// ──────────────────────────────────────────────
// GET /api/leave
// Fetches leaves based on logged-in user's role
// ──────────────────────────────────────────────
router.get('/', auth, async (req, res) => {
  try {
    const user = await User.findById(req.user.id);
    let query = {};

    if (user.role === 'Student') {
      // Students see their own leaves
      query = { applicant: user._id };
    } 
    else if (user.role === 'Teacher') {
      // Teachers see PENDING student leaves from their department & semester
      // OR Teachers see their own leaves they applied for
      query = {
        $or: [
          { approverRole: 'Teacher', department: user.department, status: 'Pending' },
          { applicant: user._id, applicantRole: 'Teacher' }
        ]
      };
    } 
    else if (user.role === 'HOD') {
      // HODs see PENDING teacher leaves from their department
      // OR HODs see their own leaves they applied for (if any)
      query = {
        $or: [
          { approverRole: 'HOD', department: user.department, status: 'Pending' },
          { applicant: user._id, applicantRole: 'HOD' }
        ]
      };
    }

    const leaves = await Leave.find(query)
                              .populate('applicant', 'name teacherId studentId department semester')
                              .sort({ createdAt: -1 });
                              
    res.json({ data: leaves });

  } catch (error) {
    res.status(500).json({ message: 'Server error', error: error.message });
  }
});

// ──────────────────────────────────────────────
// PUT /api/leave/:id
// Approve or Reject a leave
// ──────────────────────────────────────────────
router.put('/:id', auth, async (req, res) => {
  try {
    const { status } = req.body; // Expecting 'Approved' or 'Rejected'
    const user = await User.findById(req.user.id);
    const leave = await Leave.findById(req.params.id);

    if (!leave) return res.status(404).json({ message: 'Leave not found' });

    // Security check: Ensure the person approving is actually the correct role
    if (leave.approverRole !== user.role) {
      return res.status(403).json({ message: 'You are not authorized to approve this leave' });
    }

    leave.status = status;
    await leave.save();

    res.json({ message: `Leave ${status.toLowerCase()} successfully`, data: leave });

  } catch (error) {
    res.status(500).json({ message: 'Server error', error: error.message });
  }
});

module.exports = router;