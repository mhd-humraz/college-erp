<<<<<<< HEAD
<<<<<<< HEAD
// edusphere-backend/seed.js

const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');
const User = require('./models/User');

const MONGO_URI = 'mongodb://localhost:27017/edusphere';

const users = [
  {
    email: 'admin@edusphere.edu',
    password: 'admin123',
    role: 'Admin',
  },
  {
    email: 'hod@edusphere.edu',
    password: 'hod123',
    role: 'HOD',
  },
  {
    email: 'classteacher@edusphere.edu',
    password: 'class123',
    role: 'Teacher',
  },
  {
    email: 'teacher@edusphere.edu',
    password: 'teacher123',
    role: 'Teacher',
  },
  {
    email: 'student@edusphere.edu',
    password: 'student123',
    role: 'Student',
  },
];

async function seedUsers() {
  try {
    await mongoose.connect(MONGO_URI);
    console.log('✅ Connected to MongoDB');

    for (const account of users) {
      // Remove existing user with same email
      await User.deleteOne({ email: account.email });

      const hashedPassword = await bcrypt.hash(account.password, 10);

      await User.create({
        email: account.email,
        password: hashedPassword,
        role: account.role,
        isActive: true,
      });

      console.log(
        `✔ ${account.role} created -> ${account.email} / ${account.password}`
      );
    }

    console.log('\n🎉 All demo accounts created successfully.');
    process.exit(0);
  } catch (err) {
    console.error(err);
    process.exit(1);
  }
}

seedUsers();
=======
const mongoose = require("mongoose");
const bcrypt = require("bcryptjs");
const User = require("./models/User");

const MONGO_URI = "mongodb://localhost:27017/edusphere";

const users = [
    {
        name: "System Administrator",
        email: "admin@edusphere.edu",
        password: "admin123",
        role: "Admin"
    },
    {
        name: "Dr. Anu Varghese",
        email: "teacher@edusphere.edu",
        password: "teacher123",
        role: "Teacher"
    },
    {
        name: "Dr. Nikhila Raj",
        email: "hod@edusphere.edu",
        password: "hod123",
        role: "HOD"
    },
    {
        name: "Class Teacher",
        email: "classteacher@edusphere.edu",
        password: "class123",
        role: "Teacher"
    },
    {
        name: "Muhammed Humraz",
        email: "student@edusphere.edu",
        password: "student123",
        role: "Student"
    }
];

async function seedUsers() {

    try {

        await mongoose.connect(MONGO_URI);

        console.log("✅ Connected to MongoDB");

        for (const account of users) {

            await User.deleteOne({
                email: account.email
            });

            const hashedPassword =
                await bcrypt.hash(
                    account.password,
                    10
                );

            await User.create({

                name: account.name,

                email: account.email,

                password: hashedPassword,

                role: account.role,

                isActive: true

            });

            console.log(
                `✔ ${account.role} created -> ${account.email}`
            );

        }

        console.log(
            "\n🎉 All demo accounts created successfully."
        );

        process.exit(0);

    } catch (err) {

        console.error(err);

        process.exit(1);

    }

}

seedUsers();
>>>>>>> 2eaa39c (Add HOD, teacher and internal marks modules)
=======
// edusphere-backend/seed.js

const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');
const User = require('./models/User');

const MONGO_URI = 'mongodb://localhost:27017/edusphere';

const users = [
  {
    email: 'admin@edusphere.edu',
    password: 'admin123',
    role: 'Admin',
  },
  {
    email: 'hod@edusphere.edu',
    password: 'hod123',
    role: 'HOD',
  },
  {
    email: 'classteacher@edusphere.edu',
    password: 'class123',
    role: 'Teacher',
  },
  {
    email: 'teacher@edusphere.edu',
    password: 'teacher123',
    role: 'Teacher',
  },
  {
    email: 'student@edusphere.edu',
    password: 'student123',
    role: 'Student',
  },
];

async function seedUsers() {
  try {
    await mongoose.connect(MONGO_URI);
    console.log('✅ Connected to MongoDB');

    for (const account of users) {
      // Remove existing user with same email
      await User.deleteOne({ email: account.email });

      const hashedPassword = await bcrypt.hash(account.password, 10);

      await User.create({
        email: account.email,
        password: hashedPassword,
        role: account.role,
        isActive: true,
      });

      console.log(
        `✔ ${account.role} created -> ${account.email} / ${account.password}`
      );
    }

    console.log('\n🎉 All demo accounts created successfully.');
    process.exit(0);
  } catch (err) {
    console.error(err);
    process.exit(1);
  }
}

seedUsers();
>>>>>>> origin/main
