const express = require('express');
const router = express.Router();
const LibraryBook = require('../models/LibraryBook');
const BookTransaction = require('../models/BookTransaction');
const Student = require('../models/Student');
const { protect, authorize } = require('../middleware/auth');
const { asyncHandler } = require('../middleware/errorHandler');
const { calculateFine, getPagination, getPagingData } = require('../utils/helpers');
const multer = require('multer');
const path = require('path');

// Configure multer for book image uploads
const storage = multer.diskStorage({
  destination: function (req, file, cb) {
    cb(null, 'uploads/library/');
  },
  filename: function (req, file, cb) {
    cb(null, `${Date.now()}-${file.originalname.replace(/\s+/g, '-')}`);
  }
});

const upload = multer({
  storage: storage,
  limits: { fileSize: 5 * 1024 * 1024 }, // 5MB
  fileFilter: (req, file, cb) => {
    const allowedTypes = /\.(jpg|jpeg|png|gif)$/;
    const extname = path.extname(file.originalname).toLowerCase();
    if (allowedTypes.test(extname)) {
      return cb(null, true);
    }
    cb(new Error('Only images are allowed'));
  }
});

// Librarian routes
router.use(protect);
router.use(authorize('librarian', 'admin'));

// @route   GET /api/library/dashboard
// @desc    Get library dashboard statistics
router.get('/dashboard', asyncHandler(async (req, res) => {
  try {
    const stats = await Promise.all([
      LibraryBook.countDocuments(),
      LibraryBook.countDocuments({ status: 'available' }),
      BookTransaction.countDocuments({ status: 'active' }),
      BookTransaction.countDocuments({ status: 'overdue' }),
      LibraryBook.countDocuments({ 'copies.available': { $gt: 0 } })
    ]);

    // Recent transactions
    const recentTransactions = await BookTransaction.find()
      .populate('book', 'title authors barcode isbn')
      .populate('student', 'rollNumber')
      .populate('user', 'firstName lastName')
      .sort({ createdAt: -1 })
      .limit(10);

    // Overdue books list
    const overdueBooks = await BookTransaction.find({
      status: 'active',
      dueDate: { $lt: new Date() }
    })
      .populate('book', 'title authors barcode')
      .populate('student', 'rollNumber user')
      .sort({ dueDate: 1 });

    // Books due today
    const today = new Date();
    today.setHours(23, 59, 59, 999);
    const dueToday = await BookTransaction.find({
      status: 'active',
      dueDate: { $lte: today, $gte: new Date(new Date().setHours(0, 0, 0, 0)) }
    }).countDocuments();

    // Total fines pending
    const pendingFines = await BookTransaction.aggregate([
      { $match: { fineStatus: 'pending' } },
      { $group: { _id: null, totalFine: { $sum: '$fineAmount' }, count: { $sum: 1 } } }
    ]);

    res.json({
      success: true,
      data: {
        statistics: {
          totalBooks: stats[0],
          availableBooks: stats[1],
          issuedBooks: stats[2],
          overdueBooks: stats[3],
          availableCopies: stats[4],
          booksDueToday: dueToday,
          pendingFines: pendingFines[0] ? pendingFines[0].totalFine : 0,
          finePendingCount: pendingFines[0] ? pendingFines[0].count : 0
        },
        recentTransactions,
        overdueBooksList: overdueBooks
      }
    });
  } catch (error) {
    console.error('Dashboard error:', error);
    res.status(500).json({ success: false, message: 'Server error' });
  }
}));

// ==================== BOOK MANAGEMENT ====================

// @route   GET /api/library/books
// @desc    Get all books with pagination, search, filters
router.get('/books', asyncHandler(async (req, res) => {
  try {
    const { page = 1, limit = 20, search, category, status, sortBy = 'createdAt', sortOrder = 'desc' } = req.query;
    const { skip, limit: limitNum } = getPagination(page, limit);

    const query = {};
    
    if (search) {
      query.$or = [
        { title: { $regex: search, $options: 'i' } },
        { authors: { $in: [new RegExp(search, 'i')] } },
        { isbn: { $regex: search, $options: 'i' } },
        { barcode: { $regex: search, $options: 'i' } },
        { tags: { $in: [new RegExp(search, 'i')] } }
      ];
    }
    
    if (category) query.category = category;
    if (status) query.status = status;

    const sortObj = {};
    sortObj[sortBy] = sortOrder === 'asc' ? 1 : -1;

    const [books, total] = await Promise.all([
      LibraryBook.find(query)
        .sort(sortObj)
        .skip(skip)
        .limit(limitNum),
      LibraryBook.countDocuments(query)
    ]);

    res.json({
      success: true,
      data: books,
      pagination: getPagingData(total, page, limitNum)
    });
  } catch (error) {
    console.error('Get books error:', error);
    res.status(500).json({ success: false, message: 'Error fetching books' });
  }
}));

// @route   GET /api/library/books/:id
// @desc    Get single book details with transaction history
router.get('/books/:id', asyncHandler(async (req, res) => {
  try {
    const book = await LibraryBook.findById(req.params.id);
    
    if (!book) {
      return res.status(404).json({ success: false, message: 'Book not found' });
    }

    // Get transaction history for this book
    const transactionHistory = await BookTransaction.find({ book: book._id })
      .populate('student', 'rollNumber user')
      .populate('user', 'firstName lastName')
      .sort({ createdAt: -1 })
      .limit(20);

    // Current issue info
    const currentIssue = await BookTransaction.findOne({
      book: book._id,
      status: 'active'
    }).populate('student', 'rollNumber user');

    res.json({
      success: true,
      data: {
        book,
        transactionHistory,
        currentIssue
      }
    });
  } catch (error) {
    console.error('Get book error:', error);
    res.status(500).json({ success: false, message: 'Error fetching book details' });
  }
}));

// @route   POST /api/library/books
// @desc    Add new book to library
router.post('/books', upload.single('image'), asyncHandler(async (req, res) => {
  try {
    const bookData = { ...req.body };
    
    if (req.file) {
      bookData.imageUrl = `/uploads/library/${req.file.filename}`;
    }

    // Parse authors if sent as string
    if (typeof bookData.authors === 'string') {
      bookData.authors = bookData.authors.split(',').map(a => a.trim());
    }

    // Parse tags if sent as string
    if (typeof bookData.tags === 'string') {
      bookData.tags = bookData.tags.split(',').map(t => t.trim());
    }

    const book = await LibraryBook.create(bookData);

    res.status(201).json({
      success: true,
      message: 'Book added successfully',
      data: book
    });
  } catch (error) {
    console.error('Create book error:', error);
    res.status(500).json({ success: false, message: 'Error creating book' });
  }
}));

// @route   PUT /api/library/books/:id
// @desc    Update book details
router.put('/books/:id', upload.single('image'), asyncHandler(async (req, res) => {
  try {
    const updateData = { ...req.body };
    
    if (req.file) {
      updateData.imageUrl = `/uploads/library/${req.file.filename}`;
    }

    if (updateData.authors && typeof updateData.authors === 'string') {
      updateData.authors = updateData.authors.split(',').map(a => a.trim());
    }

    const book = await LibraryBook.findByIdAndUpdate(
      req.params.id,
      updateData,
      { new: true, runValidators: true }
    );

    if (!book) {
      return res.status(404).json({ success: false, message: 'Book not found' });
    }

    res.json({
      success: true,
      message: 'Book updated successfully',
      data: book
    });
  } catch (error) {
    console.error('Update book error:', error);
    res.status(500).json({ success: false, message: 'Error updating book' });
  }
}));

// @route   DELETE /api/library/books/:id
// @desc    Remove book (soft delete - mark as lost/maintenance)
router.delete('/books/:id', asyncHandler(async (req, res) => {
  try {
    const book = await LibraryBook.findByIdAndUpdate(
      req.params.id,
      { status: 'maintenance' },
      { new: true }
    );

    if (!book) {
      return res.status(404).json({ success: false, message: 'Book not found' });
    }

    res.json({
      success: true,
      message: 'Book removed from circulation'
    });
  } catch (error) {
    console.error('Delete book error:', error);
    res.status(500).json({ success: false, message: 'Error deleting book' });
  }
}));

// ==================== ISSUE/RETURN OPERATIONS ====================

// @route   POST /api/library/transactions/issue
// @desc    Issue book to student
router.post('/transactions/issue', asyncHandler(async (req, res) => {
  try {
    const { bookId, studentId, dueDays = 14 } = req.body;

    const book = await LibraryBook.findById(bookId);
    if (!book) {
      return res.status(404).json({ success: false, message: 'Book not found' });
    }

    if (book.copies.available <= 0) {
      return res.status(400).json({
        success: false,
        message: 'No copies available for issue'
      });
    }

    if (book.isReferenceOnly) {
      return res.status(400).json({
        success: false,
        message: 'Reference books cannot be issued'
      });
    }

    const student = await Student.findById(studentId);
    if (!student) {
      return res.status(404).json({ success: false, message: 'Student not found' });
    }

    // Check if student has reached maximum limit (5 books)
    const activeTransactions = await BookTransaction.countDocuments({
      student: studentId,
      status: 'active'
    });

    if (activeTransactions >= 5) {
      return res.status(400).json({
        success: false,
        message: 'Maximum book limit reached (5 books)'
      });
    }

    // Check if student has overdue books
    const overdueCount = await BookTransaction.countDocuments({
      student: studentId,
      status: 'overdue'
    });

    if (overdueCount > 0) {
      return res.status(400).json({
        success: false,
        message: 'Cannot issue books. Please clear overdue items first.'
      });
    }

    const dueDate = new Date();
    dueDate.setDate(dueDate.getDate() + dueDays);

    const transaction = await BookTransaction.create({
      book: bookId,
      student: studentId,
      user: req.user.id,
      transactionType: 'issue',
      issueDate: new Date(),
      dueDate,
      conditionOnIssue: 'good',
      issuedBy: req.user.id,
      status: 'active'
    });

    // Update book availability
    book.copies.available -= 1;
    if (book.copies.available === 0) {
      book.status = 'issued';
    }
    book.lastIssuedDate = new Date();
    await book.save();

    res.status(201).json({
      success: true,
      message: 'Book issued successfully',
      data: {
        transaction,
        book: {
          title: book.title,
          authors: book.authors,
          dueDate: dueDate.toISOString().split('T')[0]
        }
      }
    });
  } catch (error) {
    console.error('Issue book error:', error);
    res.status(500).json({ success: false, message: 'Error issuing book' });
  }
}));

// @route   POST /api/library/transactions/return
// @desc    Return book with fine calculation
router.post('/transactions/return', asyncHandler(async (req, res) => {
  try {
    const { transactionId, condition } = req.body;

    const transaction = await BookTransaction.findById(transactionId)
      .populate('book');

    if (!transaction || transaction.status !== 'active') {
      return res.status(404).json({
        success: false,
        message: 'Active transaction not found'
      });
    }

    const actualReturnDate = new Date();
    const fineAmount = calculateFine(transaction.dueDate, actualReturnDate, transaction.perDayFine);

    // Update transaction
    transaction.returnDate = actualReturnDate;
    transaction.actualReturnDate = actualReturnDate;
    transaction.conditionOnReturn = condition || 'good';
    transaction.receivedBy = req.user.id;
    transaction.transactionType = 'return';
    transaction.fineAmount = fineAmount;
    transaction.fineStatus = fineAmount > 0 ? 'pending' : 'no_fine';
    transaction.status = fineAmount > 0 ? 'overdue' : 'returned';
    await transaction.save();

    // Update book availability
    const book = await LibraryBook.findById(transaction.book._id);
    book.copies.available += 1;
    book.status = 'available';
    await book.save();

    res.json({
      success: true,
      message: fineAmount > 0 
        ? `Book returned. Fine of ₹${fineAmount.toFixed(2)} applicable.` 
        : 'Book returned successfully.',
      data: {
        transaction,
        fineDetails: {
          amount: fineAmount,
          daysOverdue: Math.max(0, Math.ceil((actualReturnDate - transaction.dueDate) / (1000 * 60 * 60 * 24))),
          perDayFine: transaction.perDayFine,
          status: fineAmount > 0 ? 'PAYMENT DUE' : 'NO FINE'
        }
      }
    });
  } catch (error) {
    console.error('Return book error:', error);
    res.status(500).json({ success: false, message: 'Error returning book' });
  }
}));

// @route   POST /api/library/transactions/:id/renew
// @desc    Renew book issuance
router.post('/transactions/:id/renew', asyncHandler(async (req, res) => {
  try {
    const transaction = await BookTransaction.findById(req.params.id);

    if (!transaction || transaction.status !== 'active') {
      return res.status(404).json({ success: false, message: 'Transaction not found or not active' });
    }

    if (transaction.renewalCount >= 3) {
      return res.status(400).json({ success: false, message: 'Maximum renewal limit (3) reached' });
    }

    // Extend due date by 14 more days
    const newDueDate = new Date(transaction.dueDate);
    newDueDate.setDate(newDueDate.getDate() + 14);

    transaction.dueDate = newDueDate;
    transaction.renewalCount += 1;
    transaction.transactionType = 'renew';
    await transaction.save();

    res.json({
      success: true,
      message: 'Book renewed successfully',
      data: {
        newDueDate: newDueDate.toISOString().split('T')[0],
        renewalsRemaining: 3 - transaction.renewalCount
      }
    });
  } catch (error) {
    console.error('Renew book error:', error);
    res.status(500).json({ success: false, message: 'Error renewing book' });
  }
}));

// @route   GET /api/library/transactions
// @desc    Get all transactions with filters
router.get('/transactions', asyncHandler(async (req, res) => {
  try {
    const { page = 1, limit = 20, status, student, book, fromDate, toDate } = req.query;
    const { skip, limit: limitNum } = getPagination(page, limit);

    const query = {};
    if (status) query.status = status;
    if (student) query.student = student;
    if (book) query.book = book;
    if (fromDate || toDate) {
      query.createdAt = {};
      if (fromDate) query.createdAt.$gte = new Date(fromDate);
      if (toDate) query.createdAt.$lte = new Date(toDate);
    }

    const [transactions, total] = await Promise.all([
      BookTransaction.find(query)
        .populate('book', 'title authors barcode isbn')
        .populate('student', 'rollNumber user')
        .populate('user', 'firstName lastName')
        .sort({ createdAt: -1 })
        .skip(skip)
        .limit(limitNum),
      BookTransaction.countDocuments(query)
    ]);

    res.json({
      success: true,
      data: transactions,
      pagination: getPagingData(total, page, limitNum)
    });
  } catch (error) {
    console.error('Get transactions error:', error);
    res.status(500).json({ success: false, message: 'Error fetching transactions' });
  }
}));

// @route   GET /api/library/transactions/overdue
// @desc    Get all overdue transactions
router.get('/transactions/overdue', asyncHandler(async (req, res) => {
  try {
    const overdueTransactions = await BookTransaction.find({
      status: 'active',
      dueDate: { $lt: new Date() }
    })
      .populate('book', 'title authors barcode')
      .populate('student', 'rollNumber user')
      .sort({ dueDate: 1 });

    // Calculate fines for each
    const overdueWithFines = overdueTransactions.map(trans => ({
      ...trans.toObject(),
      daysOverdue: Math.ceil((new Date() - trans.dueDate) / (1000 * 60 * 60 * 24)),
      calculatedFine: calculateFine(trans.dueDate, new Date(), trans.perDayFine)
    }));

    const totalFines = overdueWithFines.reduce((sum, trans) => sum + trans.calculatedFine, 0);

    res.json({
      success: true,
      data: {
        overdueTransactions: overdueWithFines,
        totalCount: overdueWithFines.length,
        totalFinesDue: totalFines
      }
    });
  } catch (error) {
    console.error('Get overdue error:', error);
    res.status(500).json({ success: false, message: 'Error fetching overdue books' });
  }
}));

// ==================== STUDENT BOOK HISTORY ====================

// @route   GET /api/library/students/:studentId/history
// @desc    Get complete borrowing history of a student
router.get('/students/:studentId/history', asyncHandler(async (req, res) => {
  try {
    const transactions = await BookTransaction.find({
      student: req.params.studentId
    })
      .populate('book', 'title authors barcode isbn category')
      .sort({ createdAt: -1 });

    // Summary statistics
    const summary = {
      totalBorrowed: transactions.length,
      currentlyIssued: transactions.filter(t => t.status === 'active').length,
      returned: transactions.filter(t => t.status === 'returned').length,
      overdue: transactions.filter(t => t.status === 'overdue').length,
      totalFinesPaid: transactions.reduce((sum, t) => sum + (t.finePaid || 0), 0),
      totalFinesPending: transactions.filter(t => t.fineStatus === 'pending')
        .reduce((sum, t) => sum + t.fineAmount, 0)
    };

    // Reading habits (most borrowed categories)
    const categoriesBorrowed = {};
    transactions.forEach(t => {
      if (t.book && t.book.category) {
        categoriesBorrowed[t.book.category] = (categoriesBorrowed[t.book.category] || 0) + 1;
      }
    });

    res.json({
      success: true,
      data: {
        history: transactions,
        summary,
        topCategories: Object.entries(categoriesBorrowed)
          .sort((a, b) => b[1] - a[1])
          .slice(0, 5)
          .map(([cat, count]) => ({ category: cat, borrowCount: count }))
      }
    });
  } catch (error) {
    console.error('Get history error:', error);
    res.status(500).json({ success: false, message: 'Error fetching history' });
  }
}));

// ==================== FINE MANAGEMENT ====================

// @route   POST /api/library/transactions/:id/pay-fine
// @desc    Mark fine as paid
router.post('/transactions/:id/pay-fine', asyncHandler(async (req, res) => {
  try {
    const { paymentMethod, receiptNumber } = req.body;

    const transaction = await BookTransaction.findById(req.params.id);

    if (!transaction || transaction.fineStatus !== 'pending') {
      return res.status(400).json({ success: false, message: 'No pending fine for this transaction' });
    }

    transaction.finePaid = transaction.fineAmount;
    transaction.fineStatus = 'paid';
    transaction.paymentMethod = paymentMethod;
    transaction.receiptNumber = receiptNumber;
    transaction.paidAt = new Date();
    await transaction.save();

    res.json({
      success: true,
      message: `Fine of ₹${transaction.fineAmount} paid successfully`,
      data: {
        receiptNumber,
        amount: transaction.fineAmount,
        paidAt: transaction.paidAt
      }
    });
  } catch (error) {
    console.error('Pay fine error:', error);
    res.status(500).json({ success: false, message: 'Error processing payment' });
  }
}));

// @route   GET /api/library/fines/pending
// @desc    Get all pending fines
router.get('/fines/pending', asyncHandler(async (req, res) => {
  try {
    const pendingFines = await BookTransaction.find({
      fineStatus: 'pending'
    })
      .populate('student', 'rollNumber user')
      .populate('book', 'title barcode')
      .sort({ dueDate: 1 });

    const totalPending = pendingFines.reduce((sum, t) => sum + t.fineAmount, 0);

    res.json({
      success: true,
      data: {
        pendingFines,
        totalAmount: totalPending,
        count: pendingFines.length
      }
    });
  } catch (error) {
    console.error('Get fines error:', error);
    res.status(500).json({ success: false, message: 'Error fetching fines' });
  }
}));

// @route   GET /api/library/statistics
// @desc    Get library statistics and analytics
router.get('/statistics', asyncHandler(async (req, res) => {
  try {
    // Most popular books (by number of issues)
    const popularBooks = await BookTransaction.aggregate([
      { $match: { transactionType: 'issue' } },
      { $group: { _id: '$book', issueCount: { $sum: 1 } } },
      { $sort: { issueCount: -1 } },
      { $limit: 10 },
      { $lookup: { from: 'librarybooks', localField: '_id', foreignField: '_id', as: 'bookInfo' } },
      { $unwind: '$bookInfo' },
      { $project: { title: '$bookInfo.title', authors: '$bookInfo.authors', issueCount: 1 } }
    ]);

    // Category distribution
    const categoryStats = await LibraryBook.aggregate([
      { $group: { _id: '$category', totalBooks: { $sum: 1 }, available: { $sum: '$copies.available' } } },
      { $sort: { totalBooks: -1 } }
    ]);

    // Monthly issue trend (last 6 months)
    const sixMonthsAgo = new Date();
    sixMonthsAgo.setMonth(sixMonthsAgo.getMonth() - 6);

    const monthlyIssues = await BookTransaction.aggregate([
      { $match: { transactionType: 'issue', createdAt: { $gte: sixMonthsAgo } } },
      { $group: { _id: { $dateToString: { format: '%Y-%m', date: '$createdAt' } }, count: { $sum: 1 } } },
      { $sort: { _id: 1 } }
    ]);

    res.json({
      success: true,
      data: {
        popularBooks,
        categoryDistribution: categoryStats,
        monthlyIssueTrend: monthlyIssues
      }
    });
  } catch (error) {
    console.error('Statistics error:', error);
    res.status(500).json({ success: false, message: 'Error fetching statistics' });
  }
}));

module.exports = router;