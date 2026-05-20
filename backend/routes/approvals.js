const express = require('express');
const router = express.Router();
const auth = require('../middleware/auth');
const Leave = require('../models/Leave');

// PUT /api/approvals/:requestId
router.put('/:requestId', auth, async (req, res) => {
  try {
    const { action } = req.body; // expects 'approve' or 'reject'
    const { requestId } = req.params;

    if (!action || (action !== 'approve' && action !== 'reject')) {
      return res.status(400).json({ success: false, message: 'Invalid action. Use approve/reject.' });
    }

    const leave = await Leave.findById(requestId);
    if (!leave) {
      return res.status(404).json({ success: false, message: 'Leave request not found' });
    }

    // Security: Ensure the logged-in user is actually the one supposed to approve this
    const user = await User.findById(req.user.id);
    if (leave.approverRole !== user.role && user.role !== 'Admin') {
      return res.status(403).json({ success: false, message: 'You are not authorized to approve this leave.' });
    }

    // Map action to status
    leave.status = action === 'approve' ? 'Approved' : 'Rejected';
    await leave.save();

    res.json({ 
      success: true, 
      message: `Leave ${leave.status.toLowerCase()} successfully`, 
      data: leave 
    });

  } catch (error) {
    res.status(500).json({ success: false, message: 'Server error', error: error.message });
  }
});

module.exports = router;