const User = require('../models/User');
const Class = require('../models/Class');
const Subject = require('../models/Subject');
const Timetable = require('../models/Timetable');
const Request = require('../models/Request');
const csv = require('csv-parser');
const fs = require('fs');

// @desc   Upload Students CSV (HOD only - filtered by department)
// @desc   Upload Students CSV (HOD only - FIXED with Bcrypt!)
exports.uploadStudentsCSV = async (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).json({
        success: false,
        message: 'Please upload a CSV file'
      });
    }

    const results = [];
    const errors = [];
    let createdCount = 0;

    console.log('📁 Starting Student CSV Upload...');

    fs.createReadStream(req.file.path)
      .pipe(csv())
      .on('data', (data) => results.push(data))
      .on('end', async () => {

        console.log(`📊 Total rows in CSV: ${results.length}`);
        console.log("CSV Results:", results);

        for (let i = 0; i < results.length; i++) {
          try {
            const row = results[i];

            console.log(`\n📝 Processing row ${i + 1}:`, row);

            // Extract data from CSV
            const name = row["Name"];
            const email = row["Email"];
            const roll_number = row["RollNumber"];
            const semester = row["Semester"] || 1;
            const section = row["Section"] || "A";
            const phone = row["Phone"];
            const role = row["Role"] || "student";

            // Validation
            if (!name || !roll_number) {
              console.warn(`⚠️ Skipping row ${i+1}: Missing name or roll number`);
              errors.push(`Missing fields in row ${i+1}: ${JSON.stringify(row)}`);
              continue;
            }

            // Generate class name
            const deptCode = "CSE"; // Adjust based on department
            const classIdStr = `${deptCode}-${semester}-${section}`;

            // Find or create class
            let classDoc = await Class.findOne({ name: classIdStr });

            if (!classDoc) {
              classDoc = await Class.create({
                name: classIdStr,
                departmentId: req.user.departmentId,
                semester: parseInt(semester),
                section
              });
              console.log(`✅ Created new class: ${classIdStr}`);
            }

            // Check duplicate student
            const existingStudent = await User.findOne({
              $or: [
                { email },
                { rollNumber: roll_number }
              ],
              role: 'student'
            });

            if (existingStudent) {
              console.warn(`⚠️ Student already exists: ${roll_number}`);
              errors.push(`Student already exists: ${roll_number}`);
              continue;
            }

            // ✅ FIXED: Generate & HASH password with bcrypt!
            const plainPassword = row["Password"] || `${roll_number}@erp`;
            const hashedPassword = await bcrypt.hash(plainPassword, 10);

            console.log(`🔐 Creating student: ${name}`);
            console.log(`   Roll Number: ${roll_number}`);
            console.log(`   Email: ${email || roll_number + '@college.edu'}`);
            console.log(`   Password (original): ${plainPassword}`);
            console.log(`   Password (hashed): ${hashedPassword.substring(0, 20)}...`);

            // ✅ Create student with HASHED password
            const newStudent = await User.create({
              name: name.trim(),
              email: (email || `${roll_number}@college.edu`).trim().toLowerCase(),
              password: hashedPassword, // ✅ HASHED NOW!
              role,
              phone,
              departmentId: req.user.departmentId,
              classId: classDoc._id,
              rollNumber: roll_number.toString()
            });

            console.log(`✅ SUCCESS: Created student ${roll_number} (ID: ${newStudent._id})`);

            // Update class strength
            classDoc.strength += 1;
            await classDoc.save();

            createdCount++;

          } catch (err) {
            console.error(`❌ ERROR processing row ${i+1}:`, err);
            errors.push(err.message);
          }
        }

        // Delete temp file
        fs.unlinkSync(req.file.path);

        console.log(`\n🎉 Student CSV Upload Complete:`);
        console.log(`   ✅ Successfully created: ${createdCount} students`);
        console.log(`   ❌ Errors: ${errors.length}`);

        res.json({
          success: true,
          message: `✅ Students uploaded successfully: ${createdCount}`,
          data: {
            createdCount,
            totalRows: results.length,
            errors: errors.slice(0, 10)
          }
        });
      });

  } catch (error) {
    console.error('💥 Fatal error in uploadStudentsCSV:', error);
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
};

// @desc   Get Department Students (HOD View)
exports.getDepartmentStudents = async (req, res) => {
  try {
    const students = await User.find({ 
      departmentId: req.user.departmentId, 
      role: 'student',
      isActive: true 
    })
      .select('-password')
      .populate('classId', 'name semester section')
      .sort({ classId: 1, name: 1 });

    res.json({ success: true, count: students.length, data: students });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

// @desc   Assign Teacher / Class Teacher
exports.assignTeacher = async (req, res) => {
  try {
    const { teacherId, classId, subjectIds, isClassTeacher } = req.body;

    const teacher = await User.findById(teacherId);
    if (!teacher || !['teacher', 'class_teacher'].includes(teacher.role)) {
      return res.status(404).json({ success: false, message: 'Teacher not found' });
    }

    // Verify teacher belongs to HOD's department
    if (teacher.departmentId?.toString() !== req.user.departmentId?.toString()) {
      return res.status(403).json({ success: false, message: 'Teacher does not belong to your department' });
    }

    const classDoc = await Class.findById(classId);
    if (!classDoc) {
      return res.status(404).json({ success: false, message: 'Class not found' });
    }

    // Update teacher
    teacher.classId = classId;
    if (isClassTeacher) {
      teacher.role = 'class_teacher';
      classDoc.classTeacherId = teacherId;
      await classDoc.save();
    }
    await teacher.save();

    // Link subjects if provided
    if (subjectIds && subjectIds.length > 0) {
      await Subject.updateMany(
        { _id: { $in: subjectIds } },
        { teacherId: teacherId }
      );
    }

    res.json({ 
      success: true, 
      message: `Teacher ${teacher.name} assigned successfully${isClassTeacher ? ' as Class Teacher' : ''}`,
      data: teacher
    });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

// @desc   Create Timetable (Single Entry or Multiple)
exports.createTimetable = async (req, res) => {
  try {
    const { day, period, classId, teacherId, subjectId, startTime, endTime, entries } = req.body;

    // Handle single entry or multiple entries
    let timetableEntries = [];

    if (entries && Array.isArray(entries)) {
      // Multiple entries (batch create)
      timetableEntries = entries.map(entry => ({
        ...entry,
        createdBy: req.user._id
      }));
    } else {
      // Single entry
      if (!day || !period || !classId || !teacherId || !subjectId) {
        return res.status(400).json({ success: false, message: 'Missing required fields: day, period, classId, teacherId, subjectId' });
      }

      timetableEntries = [{
        day,
        period: parseInt(period),
        classId,
        teacherId,
        subjectId,
        startTime: startTime || '09:00',
        endTime: endTime || '09:50',
        createdBy: req.user._id
      }];
    }

    // Verify all classes belong to HOD's department
    const classIds = [...new Set(timetableEntries.map(e => e.classId))];
    const classes = await Class.find({ _id: { $in: classIds } });
    
    for (const cls of classes) {
      if (cls.departmentId?.toString() !== req.user.departmentId?.toString()) {
        return res.status(403).json({ success: false, message: `Class ${cls.name} not in your department` });
      }
    }

    // Create entries
    const created = await Timetable.insertMany(timetableEntries);

    res.status(201).json({ 
      success: true, 
      message: `Timetable entries created: ${created.length}`,
      data: created 
    });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

// @desc   Get Timetable (All Department or By Class)
exports.getTimetable = async (req, res) => {
  try {
    const { classId } = req.params;
    
    let query = {};
    
    if (classId && classId !== 'undefined') {
      // Specific class timetable
      query = { classId };
    } else {
      // All department timetables - get all classes in department first
      const deptClasses = await Class.find(
        { departmentId: req.user.departmentId },
        '_id'
      );
      query = { classId: { $in: deptClasses.map(c => c._id) } };
    }
    
    const timetable = await Timetable.find(query)
      .populate('subjectId', 'name code type')
      .populate('teacherId', 'name email')
      .populate('classId', 'name semester section')
      .sort({ day: 1, period: 1 });

    // Group by day
    const grouped = {};
    timetable.forEach(entry => {
      if (!grouped[entry.day]) grouped[entry.day] = [];
      grouped[entry.day].push({
        _id: entry._id,
        period: entry.period,
        startTime: entry.startTime,
        endTime: entry.endTime,
        subjectId: entry.subjectId,
        teacherId: entry.teacherId,
        classId: entry.classId
      });
    });

    res.json({ success: true, data: grouped });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

// @desc   Get All Requests (Not Just Pending)
exports.getRequests = async (req, res) => {
  try {
    // ✅ IMPROVED: Return ALL requests (pending + approved + rejected), not just pending
    const requests = await Request.find({
      $or: [
        { status: { $exists: true } },
        { requestedBy: { $ne: null } }
      ]
    })
      .populate('requestedBy', 'name email role')
      .populate('classId', 'name semester section')
      .sort({ createdAt: -1 });

    res.json({ success: true, count: requests.length, data: requests });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

// @desc   Add Student Manually (Resolve Request)
exports.addStudentManually = async (req, res) => {
  try {
    const { name, email, rollNumber, semester, section, requestId, classId } = req.body;

    // Find or create class
    const deptCode = req.user.departmentId?.code || 'UNKNOWN';
    const targetClassName = classId || `${deptCode}-${semester}-${section || 'A'}`;
    
    let classDoc = await Class.findOne({ name: targetClassName });
    if (!classDoc) {
      classDoc = await Class.create({
        name: targetClassName,
        departmentId: req.user.departmentId,
        semester: parseInt(semester),
        section: section || 'A'
      });
    }

    // Create student
    const password = rollNumber + '@erp';
    const student = await User.create({
      name,
      email: email || `${rollNumber}@college.edu`,
      password,
      role: 'student',
      departmentId: req.user.departmentId,
      classId: classDoc._id,
      rollNumber
    });

    // Update request status if provided
    if (requestId) {
      await Request.findByIdAndUpdate(requestId, {
        status: 'resolved',
        resolvedAt: new Date(),
        resolvedBy: req.user._id
      });
    }

    // Update class strength
    classDoc.strength += 1;
    await classDoc.save();

    res.status(201).json({ 
      success: true, 
      message: `Student ${name} added successfully`,
      data: student 
    });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

// ==================== NEW CONTROLLER FUNCTIONS ====================

// ✅ 1. Get Teachers in Department
exports.getTeachers = async (req, res) => {
  try {
    const teachers = await User.find({
      role: { $in: ['teacher', 'class_teacher'] },
      departmentId: req.user.departmentId,
      isActive: true
    }).select('name email role phone').lean();  // ✅ Added phone field

    res.json({ success: true, count: teachers.length, data: teachers });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

// ✅ 2. Get Classes in Department
exports.getClasses = async (req, res) => {
  try {
    const classes = await Class.find({
      departmentId: req.user.departmentId
    })
    .populate('departmentId', 'name code')
    .populate('classTeacherId', 'name email')  // ✅ Also populate class teacher info
    .select('name semester section strength classTeacherId')
    .sort({ name: 1 })
    .lean();

    res.json({ success: true, count: classes.length, data: classes });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

// ✅ 3. Get Subjects in Department
exports.getSubjects = async (req, res) => {
  try {
    const subjects = await Subject.find({
      departmentId: req.user.departmentId
    })
    .populate('teacherId', 'name')  // ✅ Also populate assigned teacher
    .select('name code type credits semester')
    .sort({ name: 1 })
    .lean();

    res.json({ success: true, count: subjects.length, data: subjects });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

// ✅ 4. Update Request Status (Approve/Reject) - WITH FULL IMPLEMENTATION
exports.updateRequestStatus = async (req, res) => {
  try {
    const { requestId } = req.params;
    const { status } = req.body; // 'approved' or 'rejected'

    if (!['approved', 'rejected'].includes(status)) {
      return res.status(400).json({ success: false, message: 'Invalid status. Use "approved" or "rejected"' });
    }

    const request = await Request.findById(requestId)
      .populate('requestedBy', 'name email role')
      .populate('classId', 'name');

    if (!request) {
      return res.status(404).json({ success: false, message: 'Request not found' });
    }

    // Update request status
    request.status = status;
    request.reviewedBy = req.user._id;
    request.reviewedAt = new Date();
    await request.save();

    // ✅ If APPROVED - Actually create the student!
    if (status === 'approved' && request.requestData) {
      try {
        const { studentName, rollNumber, semester, section } = request.requestData;
        
        // Find or create class
        const deptCode = req.user.departmentId?.code || 'UNKNOWN';
        const className = `${deptCode}-${semester || '1'}-${section || 'A'}`;
        
        let classDoc = await Class.findOne({ name: className });
        if (!classDoc) {
          classDoc = await Class.create({
            name: className,
            departmentId: req.user.departmentId,
            semester: parseInt(semester) || 1,
            section: section || 'A'
          });
        }

        // Create student account
        const password = (rollNumber || 'STU') + '@erp';
        
        await User.create({
          name: studentName || 'New Student',
          email: `${rollNumber || 'stu'}@college.edu`,
          password,
          role: 'student',
          departmentId: req.user.departmentId,
          classId: classDoc._id,
          rollNumber: rollNumber || `AUTO${Date.now()}`
        });

        // Update class strength
        classDoc.strength += 1;
        await classDoc.save();

        console.log(`✅ Student created from approved request: ${studentName}`);
      } catch (createError) {
        console.error('Error creating student from request:', createError);
        // Don't fail the whole operation, just log it
      }
    }

    res.json({ 
      success: true, 
      message: `Request #${requestId.toString().slice(-6)} ${status} successfully`,
      data: request 
    });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};
// @desc   Create New Subject (HOD only)
exports.createSubject = async (req, res) => {
  try {
    console.log('📝 Creating new subject...');
    console.log('Request body:', req.body);
    console.log('HOD User:', req.user?.email);

    const { name, code, description, credits, semester, type, teacherId } = req.body;

    // Validation
    if (!name || !code) {
      return res.status(400).json({
        success: false,
        message: 'Subject name and code are required'
      });
    }

    // Check if subject code already exists in department
    const existingSubject = await Subject.findOne({ 
      code: code.toUpperCase().trim(),
      departmentId: req.user.departmentId 
    });

    if (existingSubject) {
      return res.status(400).json({
        success: false,
        message: `Subject with code "${code.toUpperCase()}" already exists in your department`
      });
    }

    // Verify teacher belongs to same department (if provided)
    if (teacherId) {
      const teacher = await User.findOne({
        _id: teacherId,
        role: { $in: ['teacher', 'class_teacher'] },
        departmentId: req.user.departmentId,
        isActive: true
      });

      if (!teacher) {
        return res.status(400).json({
          success: false,
          message: 'Invalid teacher or teacher not in your department'
        });
      }
    }

    // Create subject
    const subjectData = {
      name: name.trim(),
      code: code.toUpperCase().trim(),
      description: description || `Subject created by HOD`,
      credits: parseInt(credits) || 4,
      semester: parseInt(semester) || 3,
      type: type || 'Theory',
      departmentId: req.user.departmentId,
      teacherId: teacherId || null,
      createdBy: req.user._id
    };

    const newSubject = await Subject.create(subjectData);

    console.log(`✅ Subject created successfully: ${newSubject.name} (${newSubject.code})`);

    // Populate teacher info for response
    const populatedSubject = await Subject.findById(newSubject._id)
      .populate('teacherId', 'name email')
      .populate('departmentId', 'name code');

    res.status(201).json({
      success: true,
      message: `Subject "${name}" created successfully!`,
      data: populatedSubject
    });

  } catch (error) {
    console.error('❌ Error creating subject:', error);
    
    // Handle MongoDB duplicate key error
    if (error.code === 11000) {
      return res.status(400).json({
        success: false,
        message: 'Subject with this code already exists'
      });
    }
    
    // Handle validation errors
    if (error.name === 'ValidationError') {
      const messages = Object.values(error.errors).map(e => e.message);
      return res.status(400).json({
        success: false,
        message: messages.join(', ')
      });
    }
    
    res.status(500).json({
      success: false,
      message: error.message || 'Failed to create subject'
    });
  }
};