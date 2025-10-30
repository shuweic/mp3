import Task from '../models/Task.js'
import User from '../models/User.js'
import { buildQueryFromReq } from '../utils/parseQuery.js'
import { validateTaskPayload } from '../middleware/validators.js'

export async function getTasks(req, res, next) {
  try {
    const { where, sort, select, skip, limit, countBool } = buildQueryFromReq(req, 'tasks')

    if (countBool) {
      const n = await Task.countDocuments(where || {})
      return res.json({ message: 'OK', data: n })
    }

    let q = Task.find(where || {})
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

export async function createTask(req, res, next) {
  try {
    validateTaskPayload(req.body, false)

    const task = await Task.create(req.body)

    // If assignedUser provided
    if (req.body.assignedUser && req.body.assignedUser.trim() !== '') {
      const user = await User.findById(req.body.assignedUser)
      if (!user) {
        throw { status: 400, message: 'assignedUser not found' }
      }

      task.assignedUserName = user.name
      await task.save()

      // Add to user's pendingTasks if not completed
      if (task.completed === false) {
        if (!user.pendingTasks.includes(task._id.toString())) {
          user.pendingTasks.push(task._id.toString())
          await user.save()
        }
      }
    }

    return res.status(201).json({ message: 'Created', data: task })
  } catch (err) {
    next(err)
  }
}

export async function getTaskById(req, res, next) {
  try {
    const { select } = req.query
    const parsedSelect = select ? JSON.parse(select) : null

    let q = Task.findById(req.params.id)
    if (parsedSelect) q = q.select(parsedSelect)

    const task = await q.exec()
    if (!task) {
      return next({ status: 404, message: 'Task not found' })
    }
    return res.json({ message: 'OK', data: task })
  } catch (err) {
    next(err)
  }
}

export async function replaceTask(req, res, next) {
  try {
    validateTaskPayload(req.body, true)

    // Enforce required fields for replace
    if (!req.body.name || !req.body.deadline) {
      throw { status: 400, message: 'name and deadline are required for replacement' }
    }

    const task = await Task.findById(req.params.id)
    if (!task) {
      return next({ status: 404, message: 'Task not found' })
    }

    const oldAssignedUser = task.assignedUser
    const oldCompleted = task.completed

    // Replace fields
    task.name = req.body.name
    task.description = req.body.description || ""
    task.deadline = req.body.deadline
    task.completed = req.body.completed !== undefined ? req.body.completed : false
    task.assignedUser = req.body.assignedUser || ""

    // Handle assignment changes
    const assignmentChanged = oldAssignedUser !== task.assignedUser
    const completedChanged = oldCompleted !== task.completed

    // Remove from old user if changed or completed
    if (oldAssignedUser && (assignmentChanged || completedChanged)) {
      const oldUser = await User.findById(oldAssignedUser)
      if (oldUser) {
        oldUser.pendingTasks = oldUser.pendingTasks.filter(tid => tid !== task._id.toString())
        await oldUser.save()
      }
    }

    // Handle new assignment
    if (task.assignedUser && task.assignedUser.trim() !== '') {
      const newUser = await User.findById(task.assignedUser)
      if (!newUser) {
        throw { status: 400, message: 'assignedUser not found' }
      }

      task.assignedUserName = newUser.name

      // Add to new user's pendingTasks if not completed
      if (task.completed === false) {
        if (!newUser.pendingTasks.includes(task._id.toString())) {
          newUser.pendingTasks.push(task._id.toString())
          await newUser.save()
        }
      }
    } else {
      task.assignedUserName = 'unassigned'
    }

    await task.save()
    return res.json({ message: 'OK', data: task })
  } catch (err) {
    next(err)
  }
}

export async function deleteTask(req, res, next) {
  try {
    const task = await Task.findById(req.params.id)
    if (!task) {
      return next({ status: 404, message: 'Task not found' })
    }

    // Remove from assigned user's pendingTasks
    if (task.assignedUser && task.assignedUser.trim() !== '') {
      const user = await User.findById(task.assignedUser)
      if (user) {
        user.pendingTasks = user.pendingTasks.filter(tid => tid !== task._id.toString())
        await user.save()
      }
    }

    await Task.findByIdAndDelete(req.params.id)
    return res.status(204).json({ message: 'No Content', data: null })
  } catch (err) {
    next(err)
  }
}

