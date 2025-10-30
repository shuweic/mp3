# 🧪 API 验证指南

完整的验证流程，确保 Llama.io REST API 正常工作。

## 📋 前置条件

1. ✅ 依赖已安装 (`npm install` 已完成)
2. ⚙️ MongoDB 数据库（本地或 MongoDB Atlas）
3. 🔧 配置环境变量

---

## 步骤 1: 配置环境变量

创建 `.env` 文件：

```bash
cp .env.example .env
```

编辑 `.env` 文件，添加您的 MongoDB 连接字符串：

### 选项 A: MongoDB Atlas (推荐用于测试)

```env
MONGO_URI=mongodb+srv://username:password@cluster.mongodb.net/llama-io?retryWrites=true&w=majority
PORT=3000
```

### 选项 B: 本地 MongoDB

```env
MONGO_URI=mongodb://localhost:27017/llama-io
PORT=3000
```

---

## 步骤 2: 启动服务器

在终端中运行：

```bash
npm run dev
```

您应该看到：
```
MongoDB connected
API running on http://localhost:3000
```

✅ 如果看到这些消息，服务器启动成功！

---

## 步骤 3: 验证方法

### 方法 1: 使用自动化测试脚本（推荐）

在**新的终端窗口**中运行：

```bash
./test-api.sh
```

这个脚本会自动测试所有端点并显示结果。

---

### 方法 2: 使用 cURL 手动测试

#### 2.1 测试用户端点

**创建用户**：
```bash
curl -X POST http://localhost:3000/api/users \
  -H "Content-Type: application/json" \
  -d '{"name":"Alice Wang","email":"alice@test.com"}'
```

预期响应：
```json
{
  "message": "Created",
  "data": {
    "_id": "...",
    "name": "Alice Wang",
    "email": "alice@test.com",
    "pendingTasks": [],
    "dateCreated": "..."
  }
}
```

**获取所有用户**：
```bash
curl http://localhost:3000/api/users
```

**获取单个用户** (替换 `USER_ID`)：
```bash
curl http://localhost:3000/api/users/USER_ID
```

**用户查询 - 排序**：
```bash
curl "http://localhost:3000/api/users?sort={\"name\":1}"
```

**用户查询 - 字段选择**：
```bash
curl "http://localhost:3000/api/users?select={\"name\":1,\"email\":1}"
```

**用户计数**：
```bash
curl "http://localhost:3000/api/users?count=true"
```

#### 2.2 测试任务端点

**创建任务**：
```bash
curl -X POST http://localhost:3000/api/tasks \
  -H "Content-Type: application/json" \
  -d '{"name":"完成项目","description":"测试任务","deadline":"2025-12-31T23:59:59Z"}'
```

**获取所有任务**：
```bash
curl http://localhost:3000/api/tasks
```

**任务查询 - 过滤未完成**：
```bash
curl "http://localhost:3000/api/tasks?where={\"completed\":false}"
```

**任务查询 - 排序按截止日期**：
```bash
curl "http://localhost:3000/api/tasks?sort={\"deadline\":1}&limit=5"
```

**任务计数**：
```bash
curl "http://localhost:3000/api/tasks?count=true"
```

#### 2.3 测试数据关联

**创建分配给用户的任务** (替换 `USER_ID`)：
```bash
curl -X POST http://localhost:3000/api/tasks \
  -H "Content-Type: application/json" \
  -d '{"name":"团队会议","deadline":"2025-11-01T14:00:00Z","assignedUser":"USER_ID"}'
```

然后检查该用户的 `pendingTasks` 字段：
```bash
curl http://localhost:3000/api/users/USER_ID
```

应该包含新任务的 ID。

#### 2.4 测试 PUT 更新

**更新任务** (替换 `TASK_ID` 和 `USER_ID`)：
```bash
curl -X PUT http://localhost:3000/api/tasks/TASK_ID \
  -H "Content-Type: application/json" \
  -d '{"name":"更新的任务","deadline":"2025-12-25T00:00:00Z","completed":true,"assignedUser":"USER_ID"}'
```

#### 2.5 测试删除

**删除任务**：
```bash
curl -X DELETE http://localhost:3000/api/tasks/TASK_ID
```

预期响应：
```json
{
  "message": "No Content",
  "data": null
}
```

#### 2.6 测试错误处理

**缺少必填字段**：
```bash
curl -X POST http://localhost:3000/api/users \
  -H "Content-Type: application/json" \
  -d '{"name":"Test"}'
```

预期响应 (400)：
```json
{
  "message": "email is required",
  "data": null
}
```

**重复邮箱**：
```bash
# 创建同一邮箱两次
curl -X POST http://localhost:3000/api/users \
  -H "Content-Type: application/json" \
  -d '{"name":"Alice","email":"alice@test.com"}'
```

预期响应 (409)：
```json
{
  "message": "Email already exists",
  "data": null
}
```

**无效的 ID 格式**：
```bash
curl http://localhost:3000/api/users/invalid-id
```

预期响应 (400)：
```json
{
  "message": "Invalid ID format",
  "data": null
}
```

**资源不存在**：
```bash
curl http://localhost:3000/api/users/000000000000000000000000
```

预期响应 (404)：
```json
{
  "message": "User not found",
  "data": null
}
```

---

### 方法 3: 使用 Postman 或 Thunder Client

1. 导入以下端点集合
2. 设置基础 URL: `http://localhost:3000/api`
3. 测试每个端点

**端点列表**：
- `GET /users`
- `POST /users`
- `GET /users/:id`
- `PUT /users/:id`
- `DELETE /users/:id`
- `GET /tasks`
- `POST /tasks`
- `GET /tasks/:id`
- `PUT /tasks/:id`
- `DELETE /tasks/:id`

---

## 步骤 4: 验证高级查询功能

测试以下查询组合：

### 组合查询 1: 过滤 + 排序 + 分页
```bash
curl "http://localhost:3000/api/tasks?where={\"completed\":false}&sort={\"deadline\":1}&skip=0&limit=10"
```

### 组合查询 2: 字段选择 + 排序
```bash
curl "http://localhost:3000/api/users?select={\"name\":1,\"email\":1}&sort={\"name\":-1}"
```

### 组合查询 3: 复杂过滤
```bash
curl "http://localhost:3000/api/tasks?where={\"assignedUser\":\"\",\"completed\":false}"
```

---

## 步骤 5: 验证数据一致性

测试双向数据同步：

1. **创建用户**并记下 `_id`
2. **创建任务**分配给该用户
3. **验证**：用户的 `pendingTasks` 包含任务 ID
4. **完成任务**（PUT 设置 `completed: true`）
5. **验证**：任务从用户的 `pendingTasks` 中移除
6. **删除用户**
7. **验证**：该用户的所有任务变为 "unassigned"

---

## ✅ 验证清单

- [ ] 服务器成功启动并连接 MongoDB
- [ ] 可以创建用户 (POST /users)
- [ ] 可以创建任务 (POST /tasks)
- [ ] 可以获取列表 (GET /users, GET /tasks)
- [ ] 可以获取单个资源 (GET /users/:id, GET /tasks/:id)
- [ ] 查询参数工作正常 (where, sort, select, skip, limit, count)
- [ ] 可以更新资源 (PUT /users/:id, PUT /tasks/:id)
- [ ] 可以删除资源 (DELETE)
- [ ] 错误处理正确 (400, 404, 409, 500)
- [ ] 用户-任务关联正常工作
- [ ] 响应格式符合规范 `{message, data}`

---

## 🐛 常见问题

### 问题 1: "MONGO_URI is not set"
**解决**: 确保创建了 `.env` 文件并设置了 `MONGO_URI`

### 问题 2: "MongoServerError: bad auth"
**解决**: 检查 MongoDB 用户名和密码是否正确

### 问题 3: "ECONNREFUSED"
**解决**: 确保 MongoDB 服务正在运行（本地）或网络可访问（Atlas）

### 问题 4: 测试脚本无法执行
**解决**: 运行 `chmod +x test-api.sh`

---

## 📊 性能验证

测试 API 在负载下的表现：

```bash
# 使用 dbFill.py 填充数据（如果可用）
python3 dbFill.py -u "localhost" -p 3000 -n 20 -t 100
```

这将创建 20 个用户和 100 个任务，验证 API 处理大量数据的能力。

---

## 🎉 验证成功标准

如果以下所有项目都通过，API 验证成功：

1. ✅ 所有 CRUD 操作正常工作
2. ✅ 查询参数正确解析和应用
3. ✅ 错误处理返回正确的状态码和消息
4. ✅ 用户-任务关联双向同步
5. ✅ 响应格式一致
6. ✅ 默认限制正确应用（tasks=100, users=无限制）

---

**准备好了吗？开始验证您的 API！** 🚀

