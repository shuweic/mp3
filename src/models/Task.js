import mongoose from 'mongoose'

const taskSchema = new mongoose.Schema({
  name: {
    type: String,
    required: true
  },
  description: {
    type: String
  },
  deadline: {
    type: Date,
    required: true
  },
  completed: {
    type: Boolean,
    default: false
  },
  assignedUser: {
    type: String,
    default: ""
  },
  assignedUserName: {
    type: String,
    default: "unassigned"
  },
  dateCreated: {
    type: Date,
    default: Date.now
  }
})

export default mongoose.model('Task', taskSchema)

