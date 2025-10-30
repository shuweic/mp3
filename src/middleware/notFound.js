export default (req, res, next) => {
  next({ status: 404, message: 'Not Found', data: null })
}

