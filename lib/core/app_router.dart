// lib/core/app_router.dart
import 'package:flutter/material.dart';

import '../modules/auth/splash_screen.dart';
import '../modules/auth/login_screen.dart';
import '../modules/student/student_dashboard.dart';
import '../modules/student/attendance_screen.dart';
import '../modules/student/marks_screen.dart';
import '../modules/student/fee_screen.dart';
import '../modules/student/notifications_screen.dart'; // 🚀 FIXED: Standardized Import Match
import '../modules/student/profile_screen.dart';
import '../modules/student/leave_request_screen.dart';
import '../modules/teacher/teacher_dashboard.dart';
import '../modules/teacher/marks_entry.dart';
import '../modules/teacher/assignment_upload.dart';
import '../modules/teacher/student_list.dart';
import '../modules/teacher/study_materials.dart';
import '../modules/teacher/leave_management.dart';
import '../modules/admin/admin_dashboard.dart';
import '../modules/admin/user_management.dart';
import '../modules/admin/department_management.dart';
import '../modules/admin/course_management.dart';
import '../modules/admin/subject_management.dart';
import '../modules/admin/timetable_management.dart';
import '../modules/admin/reports_screen.dart';
import '../modules/admin/settings_screen.dart';
import '../modules/hod/hod_dashboard.dart';

class AppRouter {
  static const String splash = '/';
  static const String login = '/login';
  static const String studentDashboard = '/student/dashboard';
  static const String studentAttendance = '/student/attendance';
  static const String studentMarks = '/student/marks';
  static const String studentFees = '/student/fees';
  static const String studentNotifications = '/student/notifications';
  static const String studentProfile = '/student/profile';
  static const String studentLeaveRequest = '/student/leave_request';

  static const String teacherDashboard = '/teacher/dashboard';
  static const String teacherMarksEntry = '/teacher/marks_entry';
  static const String teacherAssignmentUpload = '/teacher/assignment_upload';
  static const String teacherStudentList = '/teacher/student_list';
  static const String teacherStudyMaterials = '/teacher/study_materials';
  static const String teacherLeaveManagement = '/teacher/leave_management';

  static const String adminDashboard = '/admin/dashboard';
  static const String adminUserManagement = '/admin/user_management';
  static const String adminDepartmentManagement = '/admin/department_management';
  static const String adminCourseManagement = '/admin/course_management';
  static const String adminSubjectManagement = '/admin/subject_management';
  static const String adminTimetableManagement = '/admin/timetable_management';
  static const String adminReports = '/admin/reports';
  static const String adminSettings = '/admin/settings';

  static const String hodDashboard = '/hod/dashboard';

  static Map<String, WidgetBuilder> get routes => {
    '/dashboard_admin': (context) => const AdminDashboard(),
    '/dashboard_teacher': (context) => const TeacherDashboard(),
    '/dashboard_student': (context) => const StudentDashboard(),
    '/dashboard_hod': (context) => const HodDashboard(),
    splash: (context) => const SplashScreen(),
    login: (context) => const LoginScreen(),
    studentDashboard: (context) => const StudentDashboard(),
    studentAttendance: (context) => const AttendanceScreen(),
    studentMarks: (context) => const MarksScreen(),
    studentFees: (context) => const FeeScreen(),
    studentNotifications: (context) => const NotificationScreen(), // 🚀 FIXED: References Correct Class
    studentProfile: (context) => const ProfileScreen(),
    studentLeaveRequest: (context) => const LeaveRequestScreen(),
    teacherDashboard: (context) => const TeacherDashboard(),
    teacherMarksEntry: (context) => const MarksEntryScreen(),
    teacherAssignmentUpload: (context) => const AssignmentUploadScreen(),
    teacherStudentList: (context) => const StudentListScreen(),
    teacherStudyMaterials: (context) => const StudyMaterialsScreen(),
    teacherLeaveManagement: (context) => const LeaveManagementScreen(),
    adminDashboard: (context) => const AdminDashboard(),
    adminUserManagement: (context) => const UserManagementScreen(),
    adminDepartmentManagement: (context) => const DepartmentManagementScreen(),
    adminCourseManagement: (context) => const CourseManagementScreen(),
    adminSubjectManagement: (context) => const SubjectManagementScreen(),
    adminTimetableManagement: (context) => const TimetableManagementScreen(),
    adminReports: (context) => const ReportsScreen(),
    adminSettings: (context) => const SettingsScreen(),
    hodDashboard: (context) => const HodDashboard(),
  };
}