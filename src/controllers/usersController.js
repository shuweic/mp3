import User from '../models/User.js'
import Task from '../models/Task.js'
import { buildQueryFromReq } from '../utils/parseQuery.js'
import { validateUserPayload } from '../middleware/validators.js'

export async function getUsers(req, res, next) {
  try {
    const { where, sort, select, skip, limit, countBool } = buildQueryFromReq(req, 'users')

    if (countBool) {
      const n = await User.countDocuments(where || {})
      return res.json({ message: 'OK', data: n })
    }

    let q = User.find(where || {})
    if (sort) q = q.sort(sort)
    if (select) q = q.select(select)
    if (skip) q = q.skip(skip)
    if (limit) q = q.limit(limit)

    const rows = await q.exec()
    return res.json({ message: 'OK', data: rows })
  } catch (err) {
    next(err)
  }
}

export async function createUser(req, res, next) {
  try {
    validateUserPayload(req.body, false)
    const user = await User.create(req.body)
    return res.status(201).json({ message: 'Created', data: user })
  } catch (err) {
    next(err)
  }
}

export async function getUserById(req, res, next) {
  try {
    const { select } = req.query
    const parsedSelect = select ? JSON.parse(select) : null

    let q = User.findById(req.params.id)
    if (parsedSelect) q = q.select(parsedSelect)

    const user = await q.exec()
    if (!user) {
      return next({ status: 404, message: 'User not found' })
    }
    return res.json({ message: 'OK', data: user })
  } catch (err) {
    next(err)
  }
}

export async function replaceUser(req, res, next) {
  try {
    validateUserPayload(req.body, true)

    // Enforce required fields for replace
    if (!req.body.name || !req.body.email) {
      throw { status: 400, message: 'name and email are required for replacement' }
    }

    const user = await User.findById(req.params.id)
    if (!user) {
      return next({ status: 404, message: 'User not found' })
    }

    const oldPendingTasks = [...user.pendingTasks]
    const newPendingTasks = req.body.pendingTasks || []

    // Replace fields
    user.name = req.body.name
    user.email = req.body.email
    user.pendingTasks = newPendingTasks

    await user.save()

    // Sync tasks
    // Tasks no longer assigned to this user
    const removedTasks = oldPendingTasks.filter(tid => !newPendingTasks.includes(tid))
    await Task.updateMany(
      { _id: { $in: removedTasks } },
      { assignedUser: "", assignedUserName: "unassigned" }
    )

    // Tasks newly assigned or still assigned
    for (const taskId of newPendingTasks) {
      const task = await Task.findById(taskId)
      if (task) {
        task.assignedUser = user._id.toString()
        task.assignedUserName = user.name
        await task.save()
      }
    }

    // Re-fetch user's pendingTasks from DB (only incomplete tasks)
    const incompleteTasks = await Task.find({
      assignedUser: user._id.toString(),
      completed: false
    }).select('_id')
    user.pendingTasks = incompleteTasks.map(t => t._id.toString())
    await user.save()

    return res.json({ message: 'OK', data: user })
  } catch (err) {
    next(err)
  }
}

export async function deleteUser(req, res, next) {
  try {
    const user = await User.findById(req.params.id)
    if (!user) {
      return next({ status: 404, message: 'User not found' })
    }

    // Unassign incomplete tasks
    await Task.updateMany(
      { assignedUser: user._id.toString(), completed: false },
      { assignedUser: "", assignedUserName: "unassigned" }
    )

    user.pendingTasks = []
    await user.save()

    await User.findByIdAndDelete(req.params.id)
    return res.status(204).json({ message: 'No Content', data: null })
  } catch (err) {
    next(err)
  }
}

