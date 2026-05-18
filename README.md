# Smart College ERP Management System

A centralized **College ERP (Enterprise Resource Planning) System** developed using **Flutter**, **Node.js**, and **MongoDB** to manage academic and administrative activities digitally.

---
noted 

# 📌 Project Aim

The main aim of this project is to develop a centralized College ERP system that helps manage college operations efficiently through a digital platform.

The system provides separate portals for:

- Admin
- Faculty
- Students

This ERP system automates:

- Student management
- Attendance management
- Marks management
- Timetable scheduling
- Assignment handling
- Fee management
- Notifications and announcements

---

# 📖 Abstract

The College ERP Management System is a digital platform designed to simplify and automate college activities.

The application provides different dashboards and functionalities based on user roles such as:

- Administrator
- Faculty
- Student

The frontend is developed using **Flutter** for cross-platform mobile application support, while the backend is developed using **Node.js + Express.js** for handling APIs and server-side logic.

**MongoDB** is used as the database for storing institutional data securely.

The system improves communication, reduces paperwork, ensures data security, and provides real-time access to academic information.

---

# 🚀 Tech Stack

## Frontend
- Flutter
- Dart

## Backend
- Node.js
- Express.js

## Database
- MongoDB

## Authentication
- JWT Authentication

## API Communication
- REST API

---

# 🏗️ System Architecture

```text
Flutter Mobile App
        ↓
REST API
        ↓
Node.js + Express Backend
        ↓
MongoDB Database
```
# 👥 User Roles

## 1. Admin

### Responsibilities

- Manage students
- Manage teachers
- Create departments
- Manage courses
- Generate reports
- Manage fee details
- Publish notices

---

## 2. Faculty / Teacher

### Responsibilities

- Mark attendance
- Upload marks
- Manage assignments
- View timetable
- Communicate with students

---

## 3. Student

### Responsibilities

- View attendance
- View marks
- Access assignments
- View notices
- Check timetable
- Pay fees

---

# 📚 Modules

## 1. Authentication Module

### Pages

- Splash Screen
- Login Screen
- Forgot Password
- OTP Verification

### Workflow

```text
User Login
    ↓
Validate Credentials
    ↓
Generate JWT Token
    ↓
Open Dashboard
```

---

## 2. Dashboard Module

### Admin Dashboard

- Total Students
- Total Teachers
- Fee Collection
- Attendance Statistics

### Teacher Dashboard

- Today's Classes
- Attendance Shortcut
- Assignment Upload

### Student Dashboard

- Attendance Percentage
- Marks Summary
- Notifications
- Upcoming Exams

---

## 3. Student Management Module

### Pages

- Add Student
- Edit Student
- Student List
- Student Profile

### Workflow

```text
Admin Adds Student
        ↓
Data Validation
        ↓
Save to Database
        ↓
Generate Roll Number
```

---

## 4. Attendance Module

### Pages

- Take Attendance
- Attendance History
- Monthly Attendance Report

### Workflow

```text
Teacher Selects Class
        ↓
Select Subject
        ↓
Mark Attendance
        ↓
Store Attendance
        ↓
Students View Attendance
```

---

## 5. Marks Management Module

### Pages

- Upload Marks
- Internal Assessment
- Semester Results
- Grade Report

### Workflow

```text
Teacher Uploads Marks
        ↓
Calculate Total and Grade
        ↓
Store Results
        ↓
Student Views Marks
```

---

## 6. Timetable Module

### Pages

- Create Timetable
- View Timetable

---

## 7. Assignment Module

### Pages

- Upload Assignment
- Submit Assignment
- View Submissions

---

## 8. Notice Module

### Pages

- Add Notice
- View Notices

---

# 🗄️ Database Collections

```text
users
students
teachers
attendance
marks
fees
departments
subjects
assignments
notices
timetable
```

---

# 🔌 REST API Examples

## Authentication API

```http
POST /api/auth/login
POST /api/auth/register
```

## Student APIs

```http
GET /api/students
POST /api/students
PUT /api/students/:id
DELETE /api/students/:id
```

## Attendance APIs

```http
POST /api/attendance
GET /api/attendance/student/:id
```

---

# 📁 Project Structure

## Flutter Structure

```text
lib/
 ├── screens/
 ├── widgets/
 ├── services/
 ├── providers/
 ├── models/
 ├── utils/
 └── main.dart
```

## Node.js Backend Structure

```text
backend/
 ├── routes/
 ├── controllers/
 ├── models/
 ├── middleware/
 ├── config/
 ├── uploads/
 └── server.js
```

---

# 📦 Recommended Flutter Packages

| Purpose | Package |
|---|---|
| State Management | provider / riverpod |
| API Calls | dio |
| Local Storage | shared_preferences |
| JWT Handling | jwt_decoder |
| Charts | fl_chart |
| Form Validation | form_field_validator |

---

# 🔄 Complete Workflow

```text
Admin Creates Departments
            ↓
Admin Adds Teachers
            ↓
Admin Adds Students
            ↓
Teacher Marks Attendance
            ↓
Teacher Uploads Marks
            ↓
Students Access Information
            ↓
Admin Monitors Reports
```

---

# 🎨 UI Design Guidelines

## Font Usage

| Usage | Font |
|---|---|
| Headings | Poppins SemiBold |
| Dashboard Titles | Poppins Bold |
| Body Text | Poppins Regular |
| Small Labels | Poppins Medium |

---

# 🎨 Color Palette

Palette Reference:

https://colorhunt.co/palette/222831393e4600adb5eeeeee

| Purpose | Color | Hex |
|---|---|---|
| Primary Dark | Dark Gray | `#222831` |
| Secondary Dark | Gray | `#393E46` |
| Accent Color | Cyan | `#00ADB5` |
| Background Light | Off White | `#EEEEEE` |

---

# 🧭 Navigation Structure

```text
Login
  ↓
Dashboard
  ├── Students
  ├── Attendance
  ├── Marks
  ├── Assignments
  ├── Timetable
  ├── Notices
  └── Settings
```

---

# 🔮 Future Enhancements

- AI Chatbot Assistant
- Face Recognition Attendance
- QR Attendance System
- Push Notifications
- Online Fee Payment
- Analytics Dashboard

---

# ✅ Advantages

- Centralized management
- Faster data access
- Reduced manual errors
- Better communication
- Secure authentication
- Real-time updates

---

# 📌 Conclusion

The College ERP Management System provides a smart and efficient way to manage academic and administrative activities digitally.

Using Flutter and Node.js ensures:

- Scalability
- Modern UI
- Smooth API integration
- Better user experience

The system improves productivity, reduces paperwork, and enhances communication between students, faculty, and administration.

---

# 👨‍💻 Development Team

- Flutter Frontend Team
- Node.js Backend Team
- Database Management Team
- UI/UX Design Team

---

# 📄 License

This project is developed for educational purposes.