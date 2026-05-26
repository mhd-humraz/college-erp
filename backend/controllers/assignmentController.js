const Assignment = require('../models/Assignment');
const Submission = require('../models/Submission');
const StudyMaterial = require('../models/StudyMaterial');
const multer = require('multer');
const path = require('path');
const fs = require('fs');

// Configure Multer for file uploads
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    const uploadPath = 'uploads/assignments/';
    if (!fs.existsSync(uploadPath)) fs.mkdirSync(uploadPath, { recursive: true });
    cb(null, uploadPath);
  },
  filename: (req, file, cb) => {
    const uniqueName = `${Date.now()}-${Math.round(Math.random() * 1E9)}${path.extname(file.originalname)}`;
    cb(null, uniqueName);
  }
});

const fileFilter = (req, file, cb) => {
  const allowedTypes = ['.pdf', '.doc', '.docx', '.jpg', '.jpeg', '.png', '.zip'];
  const ext = path.extname(file.originalname).toLowerCase();
  if (allowedTypes.includes(ext)) {
    cb(null, true);
  } else {
    cb(new Error('Invalid file type!'), false);
  }
};

const upload = multer({ storage, fileFilter, limits: { fileSize: 10 * 1024 * 1024 } }); // 10MB

// @desc   Create Assignment (Teacher)
exports.createAssignment = async (req, res) => {
  try {
    const { title, description, subjectId, classId, dueDate, maxMarks } = req.body;

    const assignment = await Assignment.create({
      title,
      description,
      subjectId,
      classId,
      teacherId: req.user._id,
      dueDate: new Date(dueDate),
      maxMarks: maxMarks || 100
    });

    res.status(201).json({ success: true, data: assignment, message: 'Assignment created successfully!' });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

// @desc   Upload Study Material (Teacher)
exports.uploadMaterial = async (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).json({ success: false, message: 'Please select a file to upload' });
    }

    const { title, description, subjectId, classId } = req.body;

    const material = await StudyMaterial.create({
      title: title || req.file.originalname,
      description,
      fileUrl: `/uploads/assignments/${req.file.filename}`,
      fileName: req.file.originalname,
      fileType: path.extname(req.file.originalname).substring(1),
      fileSize: req.file.size,
      uploadedBy: req.user._id,
      subjectId,
      classId,
      departmentId: req.user.departmentId
    });

    res.status(201).json({ success: true, data: material, message: 'Material uploaded successfully!' });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

// @desc   Submit Assignment (Student)
exports.submitAssignment = async (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).json({ success: false, message: 'Please select a file' });
    }

    const { assignmentId } = req.body;

    const assignment = await Assignment.findById(assignmentId);
    if (!assignment) {
      return res.status(404).json({ success: false, message: 'Assignment not found' });
    }

    // Check if already submitted
    const existing = await Submission.findOne({ assignmentId, studentId: req.user._id });
    if (existing) {
      return res.status(400).json({ success: false, message: 'Already submitted!' });
    }

    // Check if late
    const isLate = new Date() > new Date(assignment.dueDate);

    const submission = await Submission.create({
      assignmentId,
      studentId: req.user._id,
      fileUrl: `/uploads/assignments/${req.file.filename}`,
      fileName: req.file.originalname,
      isLate,
      status: isLate ? 'late' : 'submitted'
    });

    // Update assignment submission count
    assignment.totalSubmissions += 1;
    await assignment.save();

    res.status(201).json({ 
      success: true, 
      data: submission, 
      message: isLate ? 'Submitted late!' : 'Submitted successfully!' 
    });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

// @desc   Get Teacher's Assignments
exports.getTeacherAssignments = async (req, res) => {
  try {
    const assignments = await Assignment.find({ teacherId: req.user._id })
      .populate('subjectId', 'name code')
      .populate('classId', 'name')
      .sort({ createdAt: -1 });

    // Add submission counts
    const enriched = await Promise.all(assignments.map(async (a) => {
      const submissions = await Submission.countDocuments({ assignmentId: a._id });
      return { ...a.toObject(), submissionCount: submissions };
    }));

    res.json({ success: true, count: enriched.length, data: enriched });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

// @desc   Get Student's Assignments
exports.getStudentAssignments = async (req, res) => {
  try {
    const studentId = req.user._id;
    const classId = req.user.classId;

    const assignments = await Assignment.find({ classId, isActive: true })
      .populate('subjectId', 'name code')
      .populate('teacherId', 'name')
      .sort({ dueDate: 1 });

    // Check submission status for each
    const enriched = await Promise.all(assignments.map(async (a) => {
      const submission = await Submission.findOne({ assignmentId: a._id, studentId });
      const isOverdue = new Date() > new Date(a.dueDate) && !submission;
      
      return {
        ...a.toObject(),
        submitted: !!submission,
        submission: submission,
        isOverdue,
        daysLeft: Math.ceil((new Date(a.dueDate) - new Date()) / (1000 * 60 * 60 * 24))
      };
    }));

    res.json({ success: true, count: enriched.length, data: enriched });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

// @desc   Get Submissions for Assignment (Teacher)
exports.getSubmissions = async (req, res) => {
  try {
    const { assignmentId } = req.params;
    
    const submissions = await Submission.find({ assignmentId })
      .populate('studentId', 'name rollNumber email')
      .sort({ submittedAt: -1 });

    res.json({ success: true, count: submissions.length, data: submissions });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

// @desc   Grade Submission (Teacher)
exports.gradeSubmission = async (req, res) => {
  try {
    const { submissionId, marks, feedback } = req.body;

    const submission = await Submission.findByIdAndUpdate(
      submissionId,
      { marks, feedback, status: 'graded' },
      { new: true }
    ).populate('studentId', 'name');

    res.json({ success: true, data: submission, message: 'Graded successfully!' });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

// @desc   Get Study Materials (Student)
exports.getMaterials = async (req, res) => {
  try {
    const query = { isActive: true };
    
    if (req.user.role === 'student') {
      query['$or'] = [
        { classId: req.user.classId },
        { departmentId: req.user.departmentId },
        { targetRole: 'student' }
      ];
    }

    const materials = await StudyMaterial.find(query)
      .populate('uploadedBy', 'name')
      .populate('subjectId', 'name')
      .sort({ createdAt: -1 });

    res.json({ success: true, count: materials.length, data: materials });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

// Export middleware
exports.uploadMiddleware = upload.single('file');