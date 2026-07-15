const express = require("express");

const router = express.Router();

const {
    createInternalMark,
    getInternalMarks,
    getStudentInternalMarks,
    getSubjectInternalMarks,
    updateInternalMark,
    deleteInternalMark
} = require("../controllers/internalMarkController");

const {
    verifyToken,
    authorizeRoles
} = require("../middleware/authMiddleware");

router.post(
    "/",
    verifyToken,
    authorizeRoles("Teacher", "HOD"),
    createInternalMark
);

router.get(
    "/",
    verifyToken,
    authorizeRoles("Admin", "HOD"),
    getInternalMarks
);

router.get(
    "/student/:studentId",
    verifyToken,
    getStudentInternalMarks
);

router.get(
    "/subject/:subjectId",
    verifyToken,
    authorizeRoles("Teacher", "HOD", "Admin"),
    getSubjectInternalMarks
);

router.put(
    "/:id",
    verifyToken,
    authorizeRoles("Teacher", "HOD"),
    updateInternalMark
);

router.delete(
    "/:id",
    verifyToken,
    authorizeRoles("HOD", "Admin"),
    deleteInternalMark
);

module.exports = router;