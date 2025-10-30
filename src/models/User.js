import mongoose from 'mongoose'

const userSchema = new mongoose.Schema({
  name: {
    type: String,
    required: true
  },
  email: {
    type: String,
    required: true,
    unique: true,
    index: true
  },
  pendingTasks: {
    type: [String],
    default: []
  },
  dateCreated: {
    type: Date,
    default: Date.now
  }
})

export default mongoose.model('User', userSchema)

