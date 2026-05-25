const User = require('../models/User');

// @desc   Login user & get token
exports.login = async (req, res) => {
  try {
    const { email, password } = req.body;

    if (!email || !password) {
      return res.status(400).json({ success: false, message: 'Please provide email and password' });
    }

    // ✅ FIXED: Changed "awaitUser" to "user"
    const user = await User.findOne({ email }).populate('departmentId classId');

    if (!user) {
      return res.status(401).json({ success: false, message: 'Invalid credentials' });
    }

    if (!user.isActive) {
      return res.status(403).json({ success: false, message: 'Your account has been deactivated' });
    }

    const isMatch = await user.matchPassword(password);

    if (!isMatch) {
      return res.status(401).json({ success: false, message: 'Invalid credentials' });
    }

    const token = user.generateToken();

    res.json({
      success: true,
      data: {
        _id: user._id,
        name: user.name,
        email: user.email,
        role: user.role,
        departmentId: user.departmentId,
        classId: user.classId,
        departmentName: user.departmentId?.name || null,
        className: user.classId?.name || null
      },
      token
    });
  } catch (error) {
    console.error('Login Error:', error);
    res.status(500).json({ success: false, message: 'Server error' });
  }
};

// @desc   Get current logged in user profile
exports.getMe = async (req, res) => {
  try {
    const user = await User.findById(req.user._id)
      .populate('departmentId', 'name code')
      .populate('classId', 'name semester section')
      .select('-password');

    res.json({ success: true, data: user });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Server error' });
  }
};