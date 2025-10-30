export function parseJSON(str, fallback) {
  try {
    return JSON.parse(str)
  } catch (err) {
    return fallback
  }
}

export function buildQueryFromReq(req, resource) {
  const { where, sort, select, skip, limit, count } = req.query

  const parsedWhere = where ? parseJSON(where, {}) : {}
  const parsedSort = sort ? parseJSON(sort, null) : null
  const parsedSelect = select ? parseJSON(select, null) : null
  const parsedSkip = skip ? Number(skip) : undefined
  let parsedLimit = limit ? Number(limit) : undefined
  const countBool = count === 'true'

  // Default limit for tasks
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

