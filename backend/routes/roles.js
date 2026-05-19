const express = require('express');
const router = express.Router();
const auth = require('../middleware/auth');

// Default permissions — in production store in DB
const defaultPermissions = {
  Teacher:   { takeAttendance: true, enterMarks: true, uploadAssignments: true, sendNotifications: false, viewReports: false, manageStudents: false, manageCourses: false, accessFee: false },
  HOD:       { takeAttendance: true, enterMarks: true, uploadAssignments: true, sendNotifications: true, viewReports: true, manageStudents: true, manageCourses: true, accessFee: false },
  Principal: { takeAttendance: true, enterMarks: true, uploadAssignments: true, sendNotifications: true, viewReports: true, manageStudents: true, manageCourses: true, accessFee: true },
  Student:   { takeAttendance: false, enterMarks: false, uploadAssignments: false, sendNotifications: false, viewReports: false, manageStudents: false, manageCourses: false, accessFee: false },
};

// GET /api/roles/permissions
router.get('/permissions', auth, async (req, res) => {
  try { res.json(defaultPermissions); }
  catch (err) { res.status(500).json({ message: err.message }); }
});

// PUT /api/roles/permissions
router.put('/permissions', auth, async (req, res) => {
  try {
    const { role, permissions } = req.body;
    if (defaultPermissions[role]) {
      Object.assign(defaultPermissions[role], permissions);
    }
    res.json({ message: `Permissions updated for ${role}`, permissions: defaultPermissions[role] });
  } catch (err) { res.status(500).json({ message: err.message }); }
});

module.exports = router;
