export function parseJSON(str, fallback, throwError = false) {
  try {
    return JSON.parse(str)
  } catch (err) {
    if (throwError) {
      const error = new Error('Invalid JSON format in query parameter')
      error.status = 400
      throw error
    }
    return fallback
  }
}

export function buildQueryFromReq(req, resource) {
  const { where, sort, select, skip, limit, count } = req.query

  // Parse JSON parameters with validation
  const parsedWhere = where ? parseJSON(where, {}, true) : {}
  const parsedSort = sort ? parseJSON(sort, null, true) : null
  const parsedSelect = select ? parseJSON(select, null, true) : null
  const parsedSkip = skip ? Number(skip) : undefined
  let parsedLimit = limit ? Number(limit) : undefined
  const countBool = count === 'true'

  // Validate skip (must be >= 0)
  if (parsedSkip !== undefined && parsedSkip < 0) {
    const error = new Error('skip parameter must be >= 0')
    error.status = 400
    throw error
  }

  // Validate limit (must be >= 0)
  if (parsedLimit !== undefined && parsedLimit < 0) {
    const error = new Error('limit parameter must be >= 0')
    error.status = 400
    throw error
  }

  // Check for count + select conflict
  if (countBool && parsedSelect) {
    const error = new Error('count and select parameters cannot be used together')
    error.status = 400
    throw error
  }

  // Default limit for tasks (but not if limit=0 is explicitly set)
  if (resource === 'tasks' && parsedLimit === undefined) {
    parsedLimit = 100
  }

  return {
    where: parsedWhere,
    sort: parsedSort,
    select: parsedSelect,
    skip: parsedSkip,
    limit: parsedLimit,
    countBool
  }
}

