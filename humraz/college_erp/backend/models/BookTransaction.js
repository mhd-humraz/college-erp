const mongoose = require('mongoose');

const bookTransactionSchema = new mongoose.Schema({
  book: { type: mongoose.Schema.Types.ObjectId, ref: 'LibraryBook', required: true },
  student: { type: mongoose.Schema.Types.ObjectId, ref: 'Student', required: true },
  user: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  transactionType: { type: String, enum: ['issue', 'return', 'renew', 'reserve', 'lost', 'fine_paid'], required: true },
  issueDate: { type: Date, required: function() { return this.transactionType === 'issue'; } },
  dueDate: { type: Date, required: function() { return this.transactionType === 'issue'; } },
  returnDate: Date,
  actualReturnDate: Date,
  renewalCount: { type: Number, default: 0, max: 3 },
  fineAmount: { type: Number, default: 0 },
  finePaid: { type: Number, default: 0 },
  fineStatus: { type: String, enum: ['no_fine', 'pending', 'paid', 'waived'], default: 'no_fine' },
  perDayFine: { type: Number, default: 5 },
  conditionOnIssue: { type: String, enum: ['good', 'fair', 'new', 'damaged'], default: 'good' },
  conditionOnReturn: { type: String, enum: ['good', 'fair', 'damaged', 'lost'] },
  remarks: String,
  issuedBy: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
  receivedBy: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
  status: { type: String, enum: ['active', 'returned', 'overdue', 'lost', 'completed'], default: 'active' }
}, { timestamps: true });

bookTransactionSchema.index({ book: 1, status: 1 });
bookTransactionSchema.index({ student: 1, status: 1 });
bookTransactionSchema.index({ dueDate: 1, status: 1 });

module.exports = mongoose.model('BookTransaction', bookTransactionSchema);