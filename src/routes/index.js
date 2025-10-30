import express from 'express'
import usersRoutes from './users.js'
import tasksRoutes from './tasks.js'

const router = express.Router()

router.use('/users', usersRoutes)
router.use('/tasks', tasksRoutes)

export default router

