import 'dotenv/config'
import mongoose from 'mongoose'
import app from './app.js'

const PORT = process.env.PORT || 3000

async function start() {
  try {
    if (!process.env.MONGO_URI) {
      console.error('MONGO_URI is not set'); process.exit(1)
    }
    await mongoose.connect(process.env.MONGO_URI)
    console.log('MongoDB connected')
    app.listen(PORT, () => console.log(`API running on http://localhost:${PORT}`))
  } catch (err) {
    console.error('Failed to start server', err.message)
    process.exit(1)
  }
}
start()

