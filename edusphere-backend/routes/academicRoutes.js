// routes/academicRoutes.js

const express = require("express");

const router = express.Router();

const academicController = require(
    "../controllers/academicController"
);

const {
    verifyToken,
    authorizeRoles
} = require(
    "../middleware/authMiddleware"
);


// ==========================================
// 1. ADMINISTRATIVE OPERATION GATEWAYS
// ==========================================

router.post(
    "/departments",
    verifyToken,
    authorizeRoles("Admin"),
    academicController.createDepartment
);

router.post(
    "/courses",
    verifyToken,
    authorizeRoles("Admin"),
    academicController.createCourse
);

router.post(
    "/subjects",
    verifyToken,
    authorizeRoles("Admin"),
    academicController.createSubject
);

router.get(
    "/subjects",
    verifyToken,
    academicController.getSubjects
);


// ==========================================
// 2. FACULTY MATRIX HUB ENDPOINTS
// ==========================================

router.post(
    "/attendance/submit",
    verifyToken,
    authorizeRoles(
        "Teacher",
        "HOD"
    ),
    academicController.submitAttendance
);

router.post(
    "/marks/submit",
    verifyToken,
    authorizeRoles(
        "Teacher",
        "HOD"
    ),
    academicController.submitMarks
);


// ==========================================
// 3. STUDENT TELEMETRY INSIGHT HOOKS
// ==========================================

router.get(
    "/student/performance/:studentId",
    verifyToken,
    authorizeRoles(
        "Student",
        "Parent",
        "Teacher"
    ),
    academicController.getStudentPerformanceSummary
);


// ==========================================
// 4. STUDENT SEMESTER RESULTS
// ==========================================

router.get(
    "/student/:studentId/results",
    verifyToken,
    authorizeRoles(
        "Student",
        "Teacher",
        "HOD",
        "Admin"
    ),
    academicController.getStudentSemesterResult
);


module.exports = router;