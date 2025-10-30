# 🦙 Llama.io REST API

Task management system REST API built with Node.js + Express + Mongoose

---

## ✅ Project Status

🎉 **Server is running at http://localhost:3000**

✅ MongoDB connected successfully  
✅ All API endpoints working properly  
✅ Basic functionality tests passed  

---

## 🚀 Quick Start

### Current Server Status

The server is already running in the background. You can test the API directly!

### Stop Server
```bash
# Find process
ps aux | grep "node src/server.js"

# Stop server
pkill -f "node src/server.js"
```

### Restart Server
```bash
npm run dev
```

---

## 🌐 API Endpoints

**Base URL**: `http://localhost:3000/api`

### User Endpoints
| Method | Path | Description |
|--------|------|-------------|
| GET | `/users` | Get all users |
| POST | `/users` | Create user |
| GET | `/users/:id` | Get single user |
| PUT | `/users/:id` | Update user |
| DELETE | `/users/:id` | Delete user |

### Task Endpoints
| Method | Path | Description |
|--------|------|-------------|
| GET | `/tasks` | Get all tasks |
| POST | `/tasks` | Create task |
| GET | `/tasks/:id` | Get single task |
| PUT | `/tasks/:id` | Update task |
| DELETE | `/tasks/:id` | Delete task |

---

## 📝 Usage Examples

### 1. Create User
```bash
curl -X POST http://localhost:3000/api/users \
  -H "Content-Type: application/json" \
  -d '{"name":"John Doe","email":"john@test.com"}'
```

### 2. Get All Users
```bash
curl http://localhost:3000/api/users
```

### 3. Create Task
```bash
curl -X POST http://localhost:3000/api/tasks \
  -H "Content-Type: application/json" \
  -d '{"name":"Learn Node.js","description":"Complete tutorial","deadline":"2025-12-31T23:59:59Z"}'
```

### 4. Get All Tasks
```bash
curl http://localhost:3000/api/tasks
```

### 5. Query Incomplete Tasks
```bash
curl "http://localhost:3000/api/tasks?where={\"completed\":false}"
```

### 6. Get Task Count
```bash
curl "http://localhost:3000/api/tasks?count=true"
```

### 7. Assign Task to User
```bash
# First get user ID
USER_ID="your_user_id"

# Create task assigned to that user
curl -X POST http://localhost:3000/api/tasks \
  -H "Content-Type: application/json" \
  -d "{\"name\":\"Team Meeting\",\"deadline\":\"2025-11-15T10:00:00Z\",\"assignedUser\":\"$USER_ID\"}"
```

---

## 🔍 Query Parameters

All GET list endpoints support:

| Parameter | Example | Description |
|-----------|---------|-------------|
| `where` | `?where={"completed":false}` | Filter criteria |
| `sort` | `?sort={"name":1}` | Sort (1=ascending, -1=descending) |
| `select` | `?select={"name":1,"email":1}` | Field selection |
| `skip` | `?skip=10` | Skip records |
| `limit` | `?limit=20` | Limit records |
| `count` | `?count=true` | Return count |

**Combined usage**:
```bash
curl "http://localhost:3000/api/tasks?where={\"completed\":false}&sort={\"deadline\":1}&limit=5"
```

---

## 📊 Data Models

### User
```json
{
  "name": "Required",
  "email": "Required, unique",
  "pendingTasks": ["Array of task IDs"],
  "dateCreated": "Auto-generated"
}
```

### Task
```json
{
  "name": "Required",
  "description": "Optional",
  "deadline": "Required",
  "completed": false,
  "assignedUser": "User ID",
  "assignedUserName": "Username or unassigned",
  "dateCreated": "Auto-generated"
}
```

---

## 🧪 Testing API

### Method 1: Run automated test script
```bash
./quick-test.sh
```

### Method 2: Manual testing
```bash
# Create user
curl -X POST http://localhost:3000/api/users \
  -H "Content-Type: application/json" \
  -d '{"name":"Test User","email":"test@example.com"}'

# Get user list
curl http://localhost:3000/api/users

# Get user count
curl "http://localhost:3000/api/users?count=true"

# Create task
curl -X POST http://localhost:3000/api/tasks \
  -H "Content-Type: application/json" \
  -d '{"name":"Test Task","deadline":"2025-12-31T23:59:59Z"}'

# Get task list
curl http://localhost:3000/api/tasks
```

---

## 🗄️ MongoDB Management

### View Data in MongoDB Atlas

1. Login to **https://cloud.mongodb.com**
2. Click **Database** → **Browse Collections**
3. Select `llama-io` database
4. View `users` and `tasks` collections

### Clean Database
If you have the `dbClean.py` script:
```bash
python3 dbClean.py -u localhost -p 3000
```

Or manually delete collections in MongoDB Atlas.

---

## 📁 Project Structure

```
mp3/
├── src/
│   ├── server.js              # Server entry point
│   ├── app.js                 # Express configuration
│   ├── models/                # Data models
│   │   ├── User.js
│   │   └── Task.js
│   ├── controllers/           # Business logic
│   │   ├── usersController.js
│   │   └── tasksController.js
│   ├── routes/                # Route definitions
│   │   ├── index.js
│   │   ├── users.js
│   │   └── tasks.js
│   ├── middleware/            # Middleware
│   │   ├── notFound.js
│   │   ├── errorHandler.js
│   │   └── validators.js
│   └── utils/                 # Utility functions
│       └── parseQuery.js
├── .env                       # Environment variables (not committed)
├── .env.example              # Environment variable template
├── package.json              # Project configuration
└── README.md                 # This file
```

---

## 🛠️ Tech Stack

- **Node.js** - JavaScript runtime
- **Express** - Web framework
- **Mongoose** - MongoDB ODM
- **MongoDB Atlas** - Cloud database
- **dotenv** - Environment variable management
- **cors** - CORS support
- **morgan** - HTTP logging

---

## ✨ Core Features

✅ RESTful API design  
✅ Complete CRUD operations  
✅ Advanced query support (filtering, sorting, pagination)  
✅ User-Task bidirectional relationship  
✅ Unified error handling  
✅ Data validation  
✅ MongoDB cloud database  

---

## 🐛 Troubleshooting

### Server won't start?
Check if `.env` file exists and MongoDB connection string is correct.

### Can't connect to MongoDB?
Make sure MongoDB Atlas Network Access allows `0.0.0.0/0`.

### API returns errors?
Check server terminal logs for detailed error messages.

---

## 🎓 CS409 MP3

This project is the MP3 assignment for CS409 course, implementing a complete RESTful API specification.

**Author**: shuweic227  
**MongoDB Cluster**: cluster0.kbr9vdt.mongodb.net  
**Deployed at**: https://cs409-mp3-api.onrender.com/api

---

**Happy coding!** 🚀
