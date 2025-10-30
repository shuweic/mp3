import express from 'express'
import {
  getUsers,
  createUser,
  getUserById,
  replaceUser,
  deleteUser
} from '../controllers/usersController.js'

const router = express.Router()

router.get('/', getUsers)
router.post('/', createUser)
router.get('/:id', getUserById)
router.put('/:id', replaceUser)
router.delete('/:id', deleteUser)

export default router

