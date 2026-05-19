const express = require('express');
const router = express.Router();
const auth = require('../middleware/auth');

// GET /api/profile
router.get('/', auth, async (req, res) => {
    try {
        const User = require('../models/User');
        const user = await User.findById(req.user.id).select('-password');
        if (!user) {
            return res.status(404).json({ message: 'User not found' });
        }
        res.json(user);
    } catch (err) {
        res.status(500).json({ message: err.message });
    }
});

// PUT /api/profile
router.put('/', auth, async (req, res) => {
    try {
        const User = require('../models/User');
        const { name, phone, department } = req.body;
        const user = await User.findByIdAndUpdate(
            req.user.id,
            { name, phone, department },
            { new: true }
        ).select('-password');
        res.json(user);
    } catch (err) {
        res.status(500).json({ message: err.message });
    }
});

module.exports = router;