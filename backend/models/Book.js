const mongoose = require('mongoose');

const bookSchema = new mongoose.Schema({
  title:     { type: String, required: true },
  author:    { type: String, required: true },
  isbn:      { type: String },
  stock:     { type: Number, default: 1 },
  available: { type: Number, default: 1 },
  category:  { type: String },
}, { timestamps: true });

const issuedSchema = new mongoose.Schema({
  bookId:      { type: mongoose.Schema.Types.ObjectId, ref: 'Book' },
  bookTitle:   { type: String },
  studentId:   { type: String, required: true },
  studentName: { type: String },
  issueDate:   { type: String },
  dueDate:     { type: String },
  returnDate:  { type: String },
  status:      { type: String, enum: ['Issued', 'Returned', 'Overdue'], default: 'Issued' },
  fine:        { type: Number, default: 0 },
}, { timestamps: true });

module.exports = {
  Book: mongoose.model('Book', bookSchema),
  IssuedBook: mongoose.model('IssuedBook', issuedSchema),
};
