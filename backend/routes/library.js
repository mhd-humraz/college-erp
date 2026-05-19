const express = require('express');
const router = express.Router();
const { Book, IssuedBook } = require('../models/Book');
const auth = require('../middleware/auth');

// Books
router.get('/books', auth, async (req, res) => {
  try { res.json(await Book.find().sort({ title: 1 })); }
  catch (err) { res.status(500).json({ message: err.message }); }
});

router.post('/books', auth, async (req, res) => {
  try {
    const book = await Book.create({ ...req.body, available: req.body.stock ?? 1 });
    res.status(201).json(book);
  } catch (err) { res.status(500).json({ message: err.message }); }
});

router.put('/books/:id', auth, async (req, res) => {
  try { res.json(await Book.findByIdAndUpdate(req.params.id, req.body, { new: true })); }
  catch (err) { res.status(500).json({ message: err.message }); }
});

router.delete('/books/:id', auth, async (req, res) => {
  try { await Book.findByIdAndDelete(req.params.id); res.json({ message: 'Book deleted' }); }
  catch (err) { res.status(500).json({ message: err.message }); }
});

// Issued books
router.get('/issued', auth, async (req, res) => {
  try { res.json(await IssuedBook.find({ status: { $ne: 'Returned' } }).sort({ createdAt: -1 })); }
  catch (err) { res.status(500).json({ message: err.message }); }
});

router.post('/issue', auth, async (req, res) => {
  try {
    const { bookId, studentId, studentName, dueDate } = req.body;
    const book = await Book.findById(bookId);
    if (!book || book.available < 1) return res.status(400).json({ message: 'Book not available' });
    const today = new Date().toISOString().split('T')[0];
    const issued = await IssuedBook.create({ bookId, bookTitle: book.title, studentId, studentName, issueDate: today, dueDate });
    book.available -= 1;
    await book.save();
    res.status(201).json(issued);
  } catch (err) { res.status(500).json({ message: err.message }); }
});

router.put('/return/:id', auth, async (req, res) => {
  try {
    const issued = await IssuedBook.findById(req.params.id);
    if (!issued) return res.status(404).json({ message: 'Record not found' });
    issued.returnDate = new Date().toISOString().split('T')[0];
    issued.status = 'Returned';
    await issued.save();
    await Book.findByIdAndUpdate(issued.bookId, { $inc: { available: 1 } });
    res.json({ message: 'Book returned' });
  } catch (err) { res.status(500).json({ message: err.message }); }
});

router.get('/fines', auth, async (req, res) => {
  try { res.json(await IssuedBook.find({ fine: { $gt: 0 } })); }
  catch (err) { res.status(500).json({ message: err.message }); }
});

module.exports = router;
