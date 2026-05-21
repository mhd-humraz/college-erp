const getPagination = (page = 1, limit = 10) => {
  const skip = (parseInt(page) - 1) * parseInt(limit);
  return { skip, limit: parseInt(limit) };
};

const getPagingData = (totalDocs, page, limit) => {
  const totalPages = Math.ceil(totalDocs / limit);
  const currentPage = parseInt(page) > totalPages ? totalPages : parseInt(page);
  return {
    totalDocs,
    limit,
    totalPages,
    currentPage,
    hasNextPage: currentPage < totalPages,
    hasPrevPage: currentPage > 1
  };
};

const calculateAttendancePercentage = (presentDays, totalDays) => {
  if (totalDays === 0) return 0;
  return Math.round((presentDays / totalDays) * 100);
};

const calculateCGPA = (marksArray) => {
  if (!marksArray || marksArray.length === 0) return 0;
  return (marksArray.reduce((sum, mark) => sum + (mark.gradePoints || 0), 0) / marksArray.length).toFixed(2);
};

const getGrade = (marks, maxMarks = 100) => {
  const percentage = (marks / maxMarks) * 100;
  if (percentage >= 90) return { grade: 'O', points: 10 };
  if (percentage >= 80) return { grade: 'A+', points: 9 };
  if (percentage >= 70) return { grade: 'A', points: 8 };
  if (percentage >= 60) return { grade: 'B+', points: 7 };
  if (percentage >= 50) return { grade: 'B', points: 6 };
  if (percentage >= 40) return { grade: 'C', points: 5 };
  return { grade: 'F', points: 0 };
};

const calculateFine = (dueDate, returnDate, perDayFine = 5) => {
  const due = new Date(dueDate);
  const returned = new Date(returnDate);
  const diffTime = Math.abs(returned - due);
  const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24));
  if (diffDays <= 0) return 0;
  return diffDays * perDayFine;
};

const formatDate = (date) => new Date(date).toLocaleDateString('en-IN', { year: 'numeric', month: 'long', day: 'numeric' });

module.exports = {
  getPagination,
  getPagingData,
  calculateAttendancePercentage,
  calculateCGPA,
  getGrade,
  calculateFine,
  formatDate
};