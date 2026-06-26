// edusphere-backend/controllers/authController.js
const User = require('../models/User');
const Student = require('../models/Student');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');

const generateTokens = (user) => {
    const accessToken = jwt.sign(
        { id: user._id, role: user.role }, 
        process.env.JWT_ACCESS_SECRET || 'edusphere_access_core_secure_string_2026', 
        { expiresIn: '1h' }
    );
    return { accessToken };
};
 
// 🚀 CORE AUTH GATEWAY: LOGIN LOGIC
exports.login = async (req, res) => {
  try {
    const { email, password } = req.body;

    const user = await User.findOne({ email });

    if (!user) {
      return res.status(401).json({
        error: "Invalid account identity credentials."
      });
    }

    const isMatch = await bcrypt.compare(
      password,
      user.password
    );

    if (!isMatch) {
      return res.status(401).json({
        error: "Invalid account identity credentials."
      });
    }

    let studentData = null;

    if (user.role === 'Student') {
      studentData = await Student.findOne({
        user: user._id
      });
    }

    const tokens = generateTokens(user);

    res.status(200).json({
      message: "Authentication successful",
      accessToken: tokens.accessToken,
      user: {
        id: user._id,
        email: user.email,
        role: user.role,

        studentId: studentData?._id,
        courseId: studentData?.course,
        semester: studentData?.semester
      }
    });

  } catch (err) {
    res.status(500).json({
      error: err.message
    });
  }
};

// 🔄 PASSWORD UPDATE GATEWAY FOR ALL VALID ROLES
exports.changePassword = async (req, res) => {
    try {
        const { oldPassword, newPassword } = req.body;
        const user = await User.findById(req.user.id);

        const isMatch = await bcrypt.compare(oldPassword, user.password);
        if (!isMatch) return res.status(400).json({ error: "Current password mismatch." });

        const salt = await bcrypt.genSalt(10);
        user.password = await bcrypt.hash(newPassword, salt);
        await user.save();

        res.status(200).json({ success: true, message: "Credential database updated cleanly." });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
};