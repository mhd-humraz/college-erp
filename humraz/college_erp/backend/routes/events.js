const express = require('express');
const router = express.Router();
const Event = require('../models/Event');
const Student = require('../models/Student');
const { protect } = require('../middleware/auth');
const { asyncHandler } = require('../middleware/errorHandler');
const { getPagination, getPagingData } = require('../utils/helpers');
const multer = require('multer');
const path = require('path');

// Configure multer for event attachments
const storage = multer.diskStorage({
  destination: function (req, file, cb) {
    cb(null, 'uploads/events/');
  },
  filename: function (req, file, cb) {
    cb(null, `${Date.now()}-${file.originalname.replace(/\s+/g, '-')}`);
  }
});

const upload = multer({
  storage: storage,
  limits: { fileSize: 10 * 1024 * 1024 }, // 10MB
  fileFilter: (req, file, cb) => {
    const allowedTypes = /\.(jpg|jpeg|png|gif|pdf|doc|docx|ppt|pptx)$/;
    const extname = path.extname(file.originalname).toLowerCase();
    if (allowedTypes.test(extname)) {
      return cb(null, true);
    }
    cb(new Error('Invalid file type'));
  }
});

// Public routes (for viewing events without authentication)
// @route   GET /api/events
// @desc    Get public events listing
router.get('/', asyncHandler(async (req, res) => {
  try {
    const { page = 1, limit = 10, type, status, category } = req.query;
    const { skip, limit: limitNum } = getPagination(page, limit);

    const query = { registrationOpen: true };
    if (type) query.type = type;
    if (status) query.status = status;
    if (category) query.category = category;

    const [events, total] = await Promise.all([
      Event.find(query)
        .populate('organizer department', 'firstName lastName name')
        .sort({ startDate: 1 })
        .skip(skip)
        .limit(limitNum),
      Event.countDocuments(query)
    ]);

    res.json({
      success: true,
      data: events,
      pagination: getPagingData(total, page, limitNum)
    });
  } catch (error) {
    console.error('Get events error:', error);
    res.status(500).json({ success: false, message: 'Error fetching events' });
  }
}));

// @route   GET /api/events/upcoming
// @desc    Get upcoming events (public)
router.get('/upcoming', asyncHandler(async (req, res) => {
  try {
    const events = await Event.find({
      status: 'upcoming',
      registrationOpen: true
    })
      .populate('organizer', 'firstName lastName')
      .sort({ startDate: 1 })
      .limit(10);

    res.json({ success: true, data: events });
  } catch (error) {
    console.error('Get upcoming events error:', error);
    res.status(500).json({ success: false, message: 'Error fetching upcoming events' });
  }
}));

// @route   GET /api/events/:id
// @desc    Get single event details (public)
router.get('/:id', asyncHandler(async (req, res) => {
  try {
    const event = await Event.findById(req.params.id)
      .populate('organizer department', 'firstName lastName name')
      .populate('coordinators', 'firstName lastName');

    if (!event) {
      return res.status(404).json({ success: false, message: 'Event not found' });
    }

    // Don't expose full participant list publicly, just count
    const eventObj = event.toObject();
    eventObj.participantCount = event.participants.length;
    eventObj.participants = undefined;

    res.json({ success: true, data: eventObj });
  } catch (error) {
    console.error('Get event error:', error);
    res.status(500).json({ success: false, message: 'Error fetching event details' });
  }
}));

// Protected routes (require authentication)
router.use(protect);

// @route   GET /api/events/my-registrations
// @desc    Get current user's event registrations
router.get('/my-registrations', asyncHandler(async (req, res) => {
  try {
    const student = await Student.findOne({ user: req.user.id });
    
    if (!student) {
      return res.status(404).json({ success: false, message: 'Student profile not found' });
    }

    const events = await Event.find({
      'participants.student': student._id
    })
      .populate('organizer department', 'firstName lastName name')
      .sort({ startDate: -1 });

    // Add participation details
    const registrations = events.map(event => {
      const participant = event.participants.find(
        p => p.student.toString() === student._id.toString()
      );
      return {
        event,
        participation: participant,
        registeredAt: participant ? participant.registeredAt : null,
        attended: participant ? participant.attended : false,
        certificateIssued: participant ? participant.certificateIssued : false
      };
    });

    res.json({ success: true, data: registrations });
  } catch (error) {
    console.error('Get registrations error:', error);
    res.status(500).json({ success: false, message: 'Error fetching registrations' });
  }
}));

// Admin/Organizer routes
// @route   POST /api/events
// @desc    Create new event
router.post('/', upload.array('attachments', 5), asyncHandler(async (req, res) => {
  try {
    let eventData = { ...req.body };
    
    // Process file attachments
    if (req.files && req.files.length > 0) {
      eventData.attachments = req.files.map(file => ({
        fileName: file.originalname,
        fileUrl: `/uploads/events/${file.filename}`,
        fileType: path.extname(file.originalname).substring(1),
        fileSize: file.size
      }));
    }

    // Set organizer and creator
    eventData.organizer = req.user.id;
    eventData.createdBy = req.user.id;

    // Parse dates properly
    if (eventData.startDate) eventData.startDate = new Date(eventData.startDate);
    if (eventData.endDate) eventData.endDate = new Date(eventData.endDate);
    if (eventData.registrationDeadline) eventData.registrationDeadline = new Date(eventData.registrationDeadline);

    // Parse rules array if sent as string
    if (eventData.rules && typeof eventData.rules === 'string') {
      eventData.rules = eventData.rules.split(',').map(r => r.trim());
    }

    const event = await Event.create(eventData);

    res.status(201).json({
      success: true,
      message: 'Event created successfully',
      data: event
    });
  } catch (error) {
    console.error('Create event error:', error);
    res.status(500).json({ success: false, message: 'Error creating event' });
  }
}));

// @route   PUT /api/events/:id
// @desc    Update event
router.put('/:id', upload.array('attachments', 5), asyncHandler(async (req, res) => {
  try {
    let event = await Event.findById(req.params.id);

    if (!event) {
      return res.status(404).json({ success: false, message: 'Event not found' });
    }

    // Check authorization (only organizer or admin can update)
    if (event.organizer.toString() !== req.user.id && req.user.role !== 'admin') {
      return res.status(403).json({
        success: false,
        message: 'Not authorized to update this event'
      });
    }

    const updateData = { ...req.body };
    
    // Handle new attachments (append to existing)
    if (req.files && req.files.length > 0) {
      const newAttachments = req.files.map(file => ({
        fileName: file.originalname,
        fileUrl: `/uploads/events/${file.filename}`,
        fileType: path.extname(file.originalname).substring(1)
      }));
      updateData.attachments = [...(event.attachments || []), ...newAttachments];
    }

    // Parse dates
    if (updateData.startDate) updateData.startDate = new Date(updateData.startDate);
    if (updateData.endDate) updateData.endDate = new Date(updateData.endDate);
    if (updateData.registrationDeadline) updateData.registrationDeadline = new Date(updateData.registrationDeadline);

    // Auto-update status based on dates
    const now = new Date();
    if (updateData.startDate) {
      if (new Date(updateData.startDate) > now) {
        updateData.status = 'upcoming';
      } else if (new Date(updateData.endDate) >= now) {
        updateData.status = 'ongoing';
      } else {
        updateData.status = 'completed';
      }
    }

    event = await Event.findByIdAndUpdate(req.params.id, updateData, {
      new: true,
      runValidators: true
    });

    res.json({
      success: true,
      message: 'Event updated successfully',
      data: event
    });
  } catch (error) {
    console.error('Update event error:', error);
    res.status(500).json({ success: false, message: 'Error updating event' });
  }
}));

// @route   DELETE /api/events/:id
// @desc    Cancel/delete event
router.delete('/:id', asyncHandler(async (req, res) => {
  try {
    const event = await Event.findById(req.params.id);

    if (!event) {
      return res.status(404).json({ success: false, message: 'Event not found' });
    }

    if (event.organizer.toString() !== req.user.id && req.user.role !== 'admin') {
      return res.status(403).json({
        success: false,
        message: 'Not authorized to delete this event'
      });
    }

    // Soft delete - mark as cancelled
    event.status = 'cancelled';
    event.registrationOpen = false;
    await event.save();

    res.json({
      success: true,
      message: 'Event cancelled successfully'
    });
  } catch (error) {
    console.error('Delete event error:', error);
    res.status(500).json({ success: false, message: 'Error deleting event' });
  }
}));

// ==================== REGISTRATION MANAGEMENT ====================

// @route   POST /api/events/:id/register
// @desc    Register for an event
router.post('/:id/register', asyncHandler(async (req, res) => {
  try {
    const student = await Student.findOne({ user: req.user.id });
    const event = await Event.findById(req.params.id);

    if (!event) {
      return res.status(404).json({ success: false, message: 'Event not found' });
    }

    if (!event.registrationOpen) {
      return res.status(400).json({
        success: false,
        message: 'Registration is closed for this event'
      });
    }

    if (new Date() > new Date(event.registrationDeadline)) {
      return res.status(400).json({
        success: false,
        message: 'Registration deadline has passed'
      });
    }

    if (event.maxParticipants && event.registeredCount >= event.maxParticipants) {
      return res.status(400).json({
        success: false,
        message: 'Event is fully booked'
      });
    }

    // Check if already registered
    const alreadyRegistered = event.participants.some(
      p => p.student.toString() === student._id.toString()
    );

    if (alreadyRegistered) {
      return res.status(400).json({
        success: false,
        message: 'Already registered for this event'
      });
    }

    // Register participant
    event.participants.push({
      student: student._id,
      user: req.user.id,
      registeredAt: new Date()
    });
    
    event.registeredCount = event.participants.length;
    await event.save();

    res.status(201).json({
      success: true,
      message: 'Successfully registered for the event',
      data: {
        eventId: event._id,
        eventName: event.title,
        registeredAt: new Date(),
        position: event.registeredCount
      }
    });
  } catch (error) {
    console.error('Register error:', error);
    res.status(500).json({ success: false, message: 'Error registering for event' });
  }
}));

// @route   DELETE /api/events/:id/register
// @desc    Cancel event registration
router.delete('/:id/register', asyncHandler(async (req, res) => {
  try {
    const student = await Student.findOne({ user: req.user.id });
    const event = await Event.findById(req.params.id);

    if (!event) {
      return res.status(404).json({ success: false, message: 'Event not found' });
    }

    // Remove participant
    const initialLength = event.participants.length;
    event.participants = event.participants.filter(
      p => p.student.toString() !== student._id.toString()
    );
    
    if (event.participants.length === initialLength) {
      return res.status(400).json({
        success: false,
        message: 'You are not registered for this event'
      });
    }

    event.registeredCount = event.participants.length;
    await event.save();

    res.json({
      success: true,
      message: 'Registration cancelled successfully'
    });
  } catch (error) {
    console.error('Cancel registration error:', error);
    res.status(500).json({ success: false, message: 'Error cancelling registration' });
  }
}));

// ==================== ORGANIZER FEATURES ====================

// @route   GET /api/events/:id/participants
// @desc    Get event participants list (organizer only)
router.get('/:id/participants', asyncHandler(async (req, res) => {
  try {
    const event = await Event.findById(req.params.id)
      .populate('participants.student', 'rollNumber')
      .populate('participants.user', 'firstName lastName email phone');

    if (!event) {
      return res.status(404).json({ success: false, message: 'Event not found' });
    }

    // Authorization check
    if (event.organizer.toString() !== req.user.id && req.user.role !== 'admin') {
      return res.status(403).json({
        success: false,
        message: 'Not authorized to view participants'
      });
    }

    res.json({
      success: true,
      data: {
        event: {
          id: event._id,
          title: event.title,
          maxParticipants: event.maxParticipants,
          registeredCount: event.registeredCount
        },
        participants: event.participants.map(p => ({
          studentId: p.student ? p.student._id : null,
          rollNumber: p.student ? p.student.rollNumber : null,
          name: p.user ? p.user.fullName : null,
          email: p.user ? p.user.email : null,
          phone: p.user ? p.user.phone : null,
          registeredAt: p.registeredAt,
          attended: p.attended,
          certificateIssued: p.certificateIssued
        })),
        statistics: {
          totalRegistered: event.registeredCount,
          attended: event.participants.filter(p => p.attended).length,
          certificatesIssued: event.participants.filter(p => p.certificateIssued).length
        }
      }
    });
  } catch (error) {
    console.error('Get participants error:', error);
    res.status(500).json({ success: false, message: 'Error fetching participants' });
  }
}));

// @route   POST /api/events/:id/attendance
// @desc    Mark attendance for event participants
router.post('/:id/attendance', asyncHandler(async (req, res) => {
  try {
    const { participants } = req.body; // Array of {studentId, attended}
    
    const event = await Event.findById(req.params.id);

    if (!event) {
      return res.status(404).json({ success: false, message: 'Event not found' });
    }

    if (event.organizer.toString() !== req.user.id && req.user.role !== 'admin') {
      return res.status(403).json({
        success: false,
        message: 'Not authorized to mark attendance'
      });
    }

    let markedCount = 0;
    for (const p of participants) {
      const participantIndex = event.participants.findIndex(
        part => part.student.toString() === p.studentId
      );
      
      if (participantIndex !== -1) {
        event.participants[participantIndex].attended = p.attended;
        if (p.attended) markedCount++;
      }
    }

    await event.save();

    res.json({
      success: true,
      message: `Attendance marked for ${markedCount} participants`,
      data: {
        totalMarked: participants.length,
        present: markedCount,
        absent: participants.length - markedCount
      }
    });
  } catch (error) {
    console.error('Mark attendance error:', error);
    res.status(500).json({ success: false, message: 'Error marking attendance' });
  }
}));

// @route   POST /api/events/:id/certificates
// @desc    Issue certificates to participants
router.post('/:id/certificates', asyncHandler(async (req, res) => {
  try {
    const { participantIds } = req.body; // Array of student IDs
    
    const event = await Event.findById(req.params.id);

    if (!event) {
      return res.status(404).json({ success: false, message: 'Event not found' });
    }

    if (event.organizer.toString() !== req.user.id && req.user.role !== 'admin') {
      return res.status(403).json({
        success: false,
        message: 'Not authorized to issue certificates'
      });
    }

    let issuedCount = 0;
    for (const studentId of participantIds) {
      const participantIndex = event.participants.findIndex(
        p => p.student.toString() === studentId
      );
      
      if (participantIndex !== -1 && event.participants[participantIndex].attended) {
        event.participants[participantIndex].certificateIssued = true;
        issuedCount++;
      }
    }

    await event.save();

    res.json({
      success: true,
      message: `Certificates issued to ${issuedCount} participants`,
      data: {
        requested: participantIds.length,
        issued: issuedCount,
        failed: participantIds.length - issuedCount
      }
    });
  } catch (error) {
    console.error('Issue certificates error:', error);
    res.status(500).json({ success: false, message: 'Error issuing certificates' });
  }
}));

// @route   POST /api/events/:id/winners
// @desc    Declare winners/positions for competition events
router.post('/:id/winners', asyncHandler(async (req, res) => {
  try {
    const { results } = req.body; // Array of {studentId, position, prize}
    
    const event = await Event.findById(req.params.id);

    if (!event) {
      return res.status(404).json({ success: false, message: 'Event not found' });
    }

    for (const result of results) {
      const participantIndex = event.participants.findIndex(
        p => p.student.toString() === result.studentId
      );
      
      if (participantIndex !== -1) {
        event.participants[participantIndex].position = result.position;
        event.participants[participantIndex].remarks = result.prize ? result.prize : '';
      }
    }

    await event.save();

    res.json({
      success: true,
      message: 'Winners declared successfully',
      data: results
    });
  } catch (error) {
    console.error('Declare winners error:', error);
    res.status(500).json({ success: false, message: 'Error declaring winners' });
  }
}));

// @route   GET /api/events/my-created
// @desc    Get events created by current user
router.get('/my-created', asyncHandler(async (req, res) => {
  try {
    const events = await Event.find({ organizer: req.user.id })
      .sort({ createdAt: -1 });

    res.json({ success: true, data: events });
  } catch (error) {
    console.error('Get created events error:', error);
    res.status(500).json({ success: false, message: 'Error fetching created events' });
  }
}));

// @route   GET /api/events/statistics
// @desc    Get event statistics (for organizers/admin)
router.get('/statistics', asyncHandler(async (req, res) => {
  try {
    // Overall event statistics
    const overallStats = await Event.aggregate([
      {
        $group: {
          _id: null,
          total: { $sum: 1 },
          upcoming: { $sum: { $cond: [{ $eq: ['$status', 'upcoming'] }, 1, 0] } },
          ongoing: { $sum: { $cond: [{ $eq: ['$status', 'ongoing'] }, 1, 0] } },
          completed: { $sum: { $cond: [{ $eq: ['$status', 'completed'] }, 1, 0] } },
          cancelled: { $sum: { $cond: [{ $eq: ['$status', 'cancelled'] }, 1, 0] } },
          totalParticipants: { $sum: { $size: '$participants' } },
          totalRegistrations: { $sum: '$registeredCount' }
        }
      }
    ]);

    // Events by type
    const byType = await Event.aggregate([
      { $group: { _id: '$type', count: { $sum: 1 } } },
      { $sort: { count: -1 } }
    ]);

    // Events by category
    const byCategory = await Event.aggregate([
      { $group: { _id: '$category', count: { $sum: 1 } } },
      { $sort: { count: -1 } }
    ]);

    // Most popular events (by registrations)
    const popularEvents = await Event.find()
      .sort({ registeredCount: -1 })
      .limit(5)
      .select('title type registeredCount maxParticipants startDate status');

    // Monthly event creation trend
    const sixMonthsAgo = new Date();
    sixMonthsAgo.setMonth(sixMonthsAgo.getMonth() - 6);

    const monthlyTrend = await Event.aggregate([
      { $match: { createdAt: { $gte: sixMonthsAgo } } },
      {
        $group: {
          _id: { $dateToString: { format: '%Y-%m', date: '$createdAt' } },
          count: { $sum: 1 }
        }
      },
      { $sort: { _id: 1 } }
    ]);

    res.json({
      success: true,
      data: {
        overall: overallStats[0] ? overallStats[0] : {},
        byType,
        byCategory,
        popularEvents,
        monthlyTrend
      }
    });
  } catch (error) {
    console.error('Get statistics error:', error);
    res.status(500).json({ success: false, message: 'Error fetching statistics' });
  }
}));

module.exports = router;