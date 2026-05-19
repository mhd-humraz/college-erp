const express = require('express');
const router = express.Router();
const Timetable = require('../models/Timetable');
const auth = require('../middleware/auth');

router.get('/', auth, async (req, res) => {
    try {
        const { teacherId, department, day } = req.query;
        const filter = {};
        if (teacherId) filter.teacherId = teacherId;
        if (department) filter.department = department;
        if (day) filter.day = day;
        res.json(await Timetable.find(filter).sort({ day: 1, time: 1 }));
    } catch (err) { res.status(500).json({ message: err.message }); }
});

router.post('/', auth, async (req, res) => {
    try { res.status(201).json(await Timetable.create(req.body)); }
    catch (err) { res.status(500).json({ message: err.message }); }
});

router.delete('/:id', auth, async (req, res) => {
    try { await Timetable.findByIdAndDelete(req.params.id); res.json({ message: 'Slot deleted' }); }
    catch (err) { res.status(500).json({ message: err.message }); }
});

module.exports = router;