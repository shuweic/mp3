# 🦙 Llama.io REST API

使用 Node.js + Express + Mongoose 构建的任务管理系统 REST API

---

## ✅ 项目状态

🎉 **服务器已启动并运行在 http://localhost:3000**

✅ MongoDB 连接成功  
✅ 所有 API 端点正常工作  
✅ 已通过基础功能测试  

---

## 🚀 快速开始

### 当前服务器正在运行

服务器已经在后台运行，您可以直接测试 API！

### 停止服务器
```bash
# 查找进程
ps aux | grep "node src/server.js"

# 停止服务器
pkill -f "node src/server.js"
```

### 重新启动服务器
```bash
npm run dev
```

---

## 🌐 API 端点

**基础 URL**: `http://localhost:3000/api`

### 用户端点
| 方法 | 路径 | 描述 |
|------|------|------|
| GET | `/users` | 获取所有用户 |
| POST | `/users` | 创建用户 |
| GET | `/users/:id` | 获取单个用户 |
| PUT | `/users/:id` | 更新用户 |
| DELETE | `/users/:id` | 删除用户 |

### 任务端点
| 方法 | 路径 | 描述 |
|------|------|------|
| GET | `/tasks` | 获取所有任务 |
| POST | `/tasks` | 创建任务 |
| GET | `/tasks/:id` | 获取单个任务 |
| PUT | `/tasks/:id` | 更新任务 |
| DELETE | `/tasks/:id` | 删除任务 |

---

## 📝 使用示例

### 1. 创建用户
```bash
curl -X POST http://localhost:3000/api/users \
  -H "Content-Type: application/json" \
  -d '{"name":"王五","email":"wangwu@test.com"}'
```

### 2. 获取所有用户
```bash
curl http://localhost:3000/api/users
```

### 3. 创建任务
```bash
curl -X POST http://localhost:3000/api/tasks \
  -H "Content-Type: application/json" \
  -d '{"name":"学习Node.js","description":"完成教程","deadline":"2025-12-31T23:59:59Z"}'
```

### 4. 获取所有任务
```bash
curl http://localhost:3000/api/tasks
```

### 5. 查询未完成的任务
```bash
curl "http://localhost:3000/api/tasks?where={\"completed\":false}"
```

### 6. 获取任务数量
```bash
curl "http://localhost:3000/api/tasks?count=true"
```

### 7. 分配任务给用户
```bash
# 先获取用户ID
USER_ID="您的用户ID"

# 创建分配给该用户的任务
curl -X POST http://localhost:3000/api/tasks \
  -H "Content-Type: application/json" \
  -d "{\"name\":\"开会\",\"deadline\":\"2025-11-15T10:00:00Z\",\"assignedUser\":\"$USER_ID\"}"
```

---

## 🔍 查询参数

所有 GET 列表端点支持：

| 参数 | 示例 | 描述 |
|------|------|------|
| `where` | `?where={"completed":false}` | 过滤条件 |
| `sort` | `?sort={"name":1}` | 排序 (1=升序, -1=降序) |
| `select` | `?select={"name":1,"email":1}` | 字段选择 |
| `skip` | `?skip=10` | 跳过记录数 |
| `limit` | `?limit=20` | 限制记录数 |
| `count` | `?count=true` | 返回计数 |

**组合使用**：
```bash
curl "http://localhost:3000/api/tasks?where={\"completed\":false}&sort={\"deadline\":1}&limit=5"
```

---

## 📊 数据模型

### User (用户)
```json
{
  "name": "必填",
  "email": "必填，唯一",
  "pendingTasks": ["任务ID列表"],
  "dateCreated": "自动生成"
}
```

### Task (任务)
```json
{
  "name": "必填",
  "description": "可选",
  "deadline": "必填",
  "completed": false,
  "assignedUser": "用户ID",
  "assignedUserName": "用户名或unassigned",
  "dateCreated": "自动生成"
}
```

---

## 🧪 测试 API

### 方法 1: 运行自动化测试脚本
```bash
./quick-test.sh
```

### 方法 2: 手动测试关键功能
```bash
# 创建用户
curl -X POST http://localhost:3000/api/users \
  -H "Content-Type: application/json" \
  -d '{"name":"测试","email":"test@example.com"}'

# 获取用户列表
curl http://localhost:3000/api/users

# 获取用户数量
curl "http://localhost:3000/api/users?count=true"

# 创建任务
curl -X POST http://localhost:3000/api/tasks \
  -H "Content-Type: application/json" \
  -d '{"name":"测试任务","deadline":"2025-12-31T23:59:59Z"}'

# 获取任务列表
curl http://localhost:3000/api/tasks
```

---

## 🗄️ MongoDB 管理

### 在 MongoDB Atlas 查看数据

1. 登录 **https://cloud.mongodb.com**
2. 点击 **Database** → **Browse Collections**
3. 选择 `llama-io` 数据库
4. 查看 `users` 和 `tasks` 集合

### 清空数据库
如果有 `dbClean.py` 脚本：
```bash
python3 dbClean.py -u localhost -p 3000
```

或者在 MongoDB Atlas 手动删除集合。

---

## 📁 项目结构

```
mp3/
├── src/
│   ├── server.js              # 服务器入口
│   ├── app.js                 # Express 配置
│   ├── models/                # 数据模型
│   │   ├── User.js
│   │   └── Task.js
│   ├── controllers/           # 业务逻辑
│   │   ├── usersController.js
│   │   └── tasksController.js
│   ├── routes/                # 路由定义
│   │   ├── index.js
│   │   ├── users.js
│   │   └── tasks.js
│   ├── middleware/            # 中间件
│   │   ├── notFound.js
│   │   ├── errorHandler.js
│   │   └── validators.js
│   └── utils/                 # 工具函数
│       └── parseQuery.js
├── .env                       # 环境变量 (不提交到Git)
├── .env.example              # 环境变量模板
├── package.json              # 项目配置
└── README.md                 # 本文件
```

---

## 🛠️ 技术栈

- **Node.js** - JavaScript 运行时
- **Express** - Web 框架
- **Mongoose** - MongoDB ODM
- **MongoDB Atlas** - 云数据库
- **dotenv** - 环境变量管理
- **cors** - 跨域支持
- **morgan** - HTTP 日志

---

## ✨ 核心特性

✅ RESTful API 设计  
✅ 完整的 CRUD 操作  
✅ 高级查询支持（过滤、排序、分页）  
✅ 用户-任务双向关联  
✅ 统一的错误处理  
✅ 数据验证  
✅ MongoDB 云数据库  

---

## 📚 相关文档

- **SETUP-GUIDE.md** - 完整的设置指南（从零开始）
- **VERIFICATION.md** - 详细的验证测试指南
- **quick-test.sh** - 快速测试脚本
- **test-api.sh** - 完整测试脚本

---

## 🐛 常见问题

### 服务器无法启动？
检查 `.env` 文件是否存在，MongoDB 连接字符串是否正确。

### 无法连接到 MongoDB？
确保 MongoDB Atlas 的 Network Access 允许 `0.0.0.0/0`。

### API 返回错误？
查看服务器终端的日志信息，通常会显示详细的错误。

---

## 🎓 CS409 MP3

本项目是 CS409 课程的 MP3 作业，实现了完整的 RESTful API 规范。

**作者**: shuweic227  
**MongoDB 集群**: cluster0.kbr9vdt.mongodb.net  

---

**祝您使用愉快！** 🚀

