class ApiError extends Error {
  constructor(statusCode, message, errors = []) {
    super(message);
    this.statusCode = statusCode;
    this.errors = errors;
    this.success = false;
  }
}

const asyncHandler = (fn) => (req, res, next) =>
  Promise.resolve(fn(req, res, next)).catch(next);

const notFound = (req, res, next) => {
  const error = new ApiError(404, `Route not found - ${req.originalUrl}`);
  next(error);
};

const errorHandler = (err, req, res, next) => {
  let error = { ...err };
  error.message = err.message;

  if (err.name === 'CastError') {
    error = new ApiError(404, 'Resource not found');
  }

  if (err.code === 11000) {
    const field = Object.keys(err.keyValue)[0];
    error = new ApiError(400, `Duplicate value for ${field}. This ${field} already exists`);
  }

  if (err.name === 'ValidationError') {
    const message = Object.values(err.errors).map(val => val.message);
    error = new ApiError(400, 'Validation Error', message);
  }

  if (err.name === 'JsonWebTokenError') {
    error = new ApiError(401, 'Invalid token');
  }

  if (err.name === 'TokenExpiredError') {
    error = new ApiError(401, 'Token expired');
  }

  res.status(error.statusCode || 500).json({
    success: false,
    message: error.message || 'Server Error',
    ...(error.errors && { errors: error.errors }),
    ...(process.env.NODE_ENV === 'development' && { stack: err.stack })
  });
};

module.exports = { ApiError, asyncHandler, notFound, errorHandler };