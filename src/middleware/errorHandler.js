export default (err, req, res, next) => {
  let status = err.status || 500
  let message = err.message || 'Internal Server Error'

  // Handle CastError
  if (err.name === 'CastError') {
    status = 400
    message = 'Invalid ID format'
  }

  // Handle duplicate key error
  if (err.code === 11000) {
    status = 409
    message = 'Email already exists'
  }

  res.status(status).json({
    message,
    data: err.data ?? null
  })
}

