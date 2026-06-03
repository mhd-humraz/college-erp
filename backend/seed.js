require('dotenv').config();
const mongoose = require('mongoose');
const User = require('./models/User');
const Department = require('./models/Department');

const MONGODB_URI = process.env.MONGODB_URI || 'mongodb://localhost:27017/college_erp2';

// Demo Data
const demoData = {
  admin: {
    name: 'Super Admin',
    email: 'admin@college.com',
    password: 'admin123',
    role: 'admin'
  },
  departments: [
    { name: 'Computer Science', code: 'BCA', description: 'Bachelor of Computer Applications' },
    { name: 'Commerce', code: 'BCom', description: 'Bachelor of Commerce' },
    { name: 'English', code: 'BA_Eng', description: 'Bachelor of Arts English' },
    { name: 'Mathematics', code: 'BSc_Maths', description: 'Bachelor of Science Maths' }
  ],
  hods: [
    { name: 'Rahul Krishnan', email: 'rahul.hod@college.com', departmentCode: 'BCA' },
    { name: 'Priya Sharma', email: 'priya.hod@college.com', departmentCode: 'BCom' }
  ],
  teachers: [
    { name: 'Shiyas VK', email: 'shiyas@college.com', departmentCode: 'BCA' },
    { name: 'Anjali Nair', email: 'anjali@college.com', departmentCode: 'BCA' },
    { name: 'Vijay Kumar', email: 'vijay@college.com', departmentCode: 'BCom' },
    { name: 'Deepa Rajan', email: 'deepa@college.com', departmentCode: 'BCom' }
  ],
  students: [
    { name: 'Ameen Hassan', rollNumber: '2401', semester: 3, section: 'A', departmentCode: 'BCA' },
    { name: 'Faris Khan', rollNumber: '2402', semester: 3, section: 'A', departmentCode: 'BCA' },
    { name: 'Sara Fathima', rollNumber: '2403', semester: 3, section: 'A', departmentCode: 'BCA' },
    { name: 'Arjun Menon', rollNumber: '2404', semester: 1, section: 'A', departmentCode: 'BCA' },
    { name: 'Divya Lakshmi', rollNumber: '2501', semester: 1, section: 'A', departmentCode: 'BCom' },
    { name: 'Karthik Raj', rollNumber: '2502', semester: 1, section: 'A', departmentCode: 'BCom' }
  ]
};

async function seedDatabase() {
  console.log('\n🌱 Seeding College ERP Database...\n');

  try {
    // Connect to MongoDB
    await mongoose.connect(MONGODB_URI);
    console.log('✅ Connected to MongoDB\n');

    // Clear existing data
    await User.deleteMany({});
    await Department.deleteMany({});
    console.log('🗑️ Cleared existing data\n');

    // 1. Create Admin
    const admin = await User.create({
      name: demoData.admin.name,
      email: demoData.admin.email,
      password: demoData.admin.password,
      role: demoData.admin.role,
      isActive: true
    });
    console.log(`✅ Admin Created:`);
    console.log(`   📧 Email: ${demoData.admin.email}`);
    console.log(`   🔑 Password: ${demoData.admin.password}\n`);

    // 2. Create Departments
    const createdDepts = [];
    for (const dept of demoData.departments) {
      const newDept = await Department.create(dept);
      createdDepts.push(newDept);
      console.log(`🏛️ Department Created: ${dept.name} (${dept.code})`);
    }

    // 3. Create HODs & Assign to Departments
    const hodUsers = [];
    for (let i = 0; i < demoData.hods.length; i++) {
      const hod = demoData.hods[i];
      const dept = createdDepts.find(d => d.code === hod.departmentCode);
      
      if (dept) {
        const hodUser = await User.create({
          name: hod.name,
          email: hod.email,
          password: 'hod123',
          role: 'hod',
          departmentId: dept._id,
          isActive: true
        });
        
        // Assign HOD to department
        dept.hodId = hodUser._id;
        await dept.save();
        hodUsers.push({ user: hodUser, dept });
        
        console.log(`\n🎓 HOD Created:`);
        console.log(`   👤 Name: ${hod.name}`);
        console.log(`   📧 Email: ${hod.email}`);
        console.log(`   🔑 Password: hod123`);
        console.log(`   🏛️ Department: ${dept.name}`);
      }
    }

    // 4. Create Teachers
    const teacherUsers = [];
    for (const teacher of demoData.teachers) {
      const dept = createdDepts.find(d => d.code === teacher.departmentCode);
      
      if (dept) {
        const teacherUser = await User.create({
          name: teacher.name,
          email: teacher.email,
          password: 'teacher123',
          role: 'teacher',
          departmentId: dept._id,
          isActive: true
        });
        teacherUsers.push(teacherUser);
        console.log(`\n👨‍🏫 Teacher Created: ${teacher.name} (${teacher.departmentCode})`);
      }
    }

    // 5. Create Students
    for (const student of demoData.students) {
      const dept = createdDepts.find(d => d.code === student.departmentCode);
      
      if (dept) {
        // Generate classId format
        const classIdStr = `${student.departmentCode}-${student.semester}-${student.section}`;
        
        await User.create({
          name: student.name,
          email: `${student.rollNumber.toLowerCase()}@student.college.edu`,
          password: student.rollNumber + '@erp',
          role: 'student',
          departmentId: dept._id,
          rollNumber: student.rollNumber,
          isActive: true
        });
        console.log(`🎓 Student Created: ${student.name} (Roll: ${student.rollNumber})`);
      }
    }

    // Print Summary
    console.log('\n' + '='.repeat(50));
    console.log('🎉 SEEDING COMPLETED SUCCESSFULLY!');
    console.log('='.repeat(50));
    
    console.log('\n📋 LOGIN CREDENTIALS:\n');
    console.log('┌─────────────────────────────────────────────┐');
    console.log('│           🔑 ALL DEMO ACCOUNTS              │');
    console.log('├─────────────────────────────────────────────┤');
    console.log('│  👑 ADMIN                                   │');
    console.log('│     Email:    admin@college.com             │');
    console.log('│     Password: admin123                      │');
    console.log('├─────────────────────────────────────────────┤');
    console.log('│  🎓 HODs                                    │');
    console.log('│     rahul.hod@college.com  / hod123         │');
    console.log('│     priya.hod@college.com  / hod123         │');
    console.log('├─────────────────────────────────────────────┤');
    console.log('│  👨‍🏫 TEACHERS                                │');
    console.log('│     shiyas@college.com     / teacher123      │');
    console.log('│     anjali@college.com     / teacher123      │');
    console.log('│     vijay@college.com      / teacher123      │');
    console.log('│     deepa@college.com      / teacher123      │');
    console.log('├─────────────────────────────────────────────┤');
    console.log('│  🎓 STUDENTS (Password = RollNo@erp)        │');
    console.log('│     2401@student.college.edu / 2401@erp      │');
    console.log('│     2402@student.college.edu / 2402@erp      │');
    console.log('│     2403@student.college.edu / 2403@erp      │');
    console.log('│     2404@student.college.edu / 2404@erp      │');
    console.log('│     2501@student.college.edu / 2501@erp      │');
    console.log('│     2502@student.college.edu / 2502@erp      │');
    console.log('└─────────────────────────────────────────────┘\n');

    process.exit(0);

  } catch (error) {
    console.error('❌ Seeding Error:', error.message);
    process.exit(1);
  }
}

seedDatabase();