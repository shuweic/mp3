import express from 'express'
import {
  getTasks,
  createTask,
  getTaskById,
  replaceTask,
  deleteTask
} from '../controllers/tasksController.js'

const router = express.Router()

router.get('/', getTasks)
router.post('/', createTask)
router.get('/:id', getTaskById)
router.put('/:id', replaceTask)
router.delete('/:id', deleteTask)

export default router

