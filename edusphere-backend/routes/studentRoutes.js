const express = require('express');
const router = express.Router();

const Student = require('../models/Student');
const upload = require('../middleware/uploadProfilePhoto');
const { verifyToken } = require('../middleware/authMiddleware');

// ===============================
// GET STUDENT PROFILE
// ===============================
router.get('/profile/:studentId', async (req, res) => {
  try {
    const student = await Student.findById(req.params.studentId)
      .populate('user', 'email role')
      .populate('department', 'name')
      .populate('course', 'name');

    if (!student) {
      return res.status(404).json({
        error: 'Student not found'
      });
    }

    res.json({
      success: true,
      student: {
        id: student._id,
        email: student.user?.email,
        role: student.user?.role,
        rollNumber: student.rollNumber,
        department: student.department?.name,
        course: student.course?.name,
        semester: student.currentSemester,
        profilePhoto: student.profilePhoto || ''
      }
    });

  } catch (err) {
    console.error(err);

    res.status(500).json({
      error: 'Failed to fetch profile'
    });
  }
});

// ===============================
// UPLOAD PROFILE PHOTO
// ===============================
router.post(
  '/upload-photo',
  verifyToken,
  upload.single('photo'),
  async (req, res) => {
    try {
      const student = await Student.findOne({
        user: req.user.id
      });

      if (!student) {
        return res.status(404).json({
          error: 'Student not found'
        });
      }

      const photoUrl =
        `http://localhost:5000/uploads/profile/${req.file.filename}`;

      student.profilePhoto = photoUrl;

      await student.save();

      res.json({
        success: true,
        message: 'Profile photo uploaded successfully',
        photo: photoUrl
      });

    } catch (err) {
      console.error(err);

      res.status(500).json({
        error: 'Failed to upload profile photo'
      });
    }
  }
);

module.exports = router;