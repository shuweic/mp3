# 🚀 完整设置指南（从零开始）

## 📋 目录
1. [设置 MongoDB Atlas（免费云数据库）](#步骤-1-设置-mongodb-atlas)
2. [配置项目](#步骤-2-配置项目)
3. [启动服务器](#步骤-3-启动服务器)
4. [验证 API](#步骤-4-验证-api)

---

## 步骤 1: 设置 MongoDB Atlas

MongoDB Atlas 是免费的云数据库服务，无需本地安装。

### 1.1 注册账号

1. 访问 **https://www.mongodb.com/cloud/atlas/register**
2. 填写注册信息（或使用 Google 账号登录）
3. 完成邮箱验证

### 1.2 创建免费集群

1. 登录后，点击 **"Build a Database"** 或 **"Create"**
2. 选择 **"FREE"** 共享集群（M0 Sandbox）
3. 选择云提供商和区域：
   - Provider: **AWS** 或 **Google Cloud**
   - Region: 选择离您最近的区域（例如：**Singapore** 或 **Hong Kong**）
4. Cluster Name: 保持默认或命名为 `Cluster0`
5. 点击 **"Create Cluster"**（需要 1-3 分钟）

### 1.3 创建数据库用户

1. 在左侧菜单点击 **"Database Access"**
2. 点击 **"Add New Database User"**
3. 选择 **"Password"** 认证方式
4. 设置用户名和密码：
   ```
   用户名: admin
   密码: 创建一个强密码（记住它！）
   ```
   ⚠️ **重要：请记下密码，后面会用到**
5. Database User Privileges: 选择 **"Read and write to any database"**
6. 点击 **"Add User"**

### 1.4 配置网络访问

1. 在左侧菜单点击 **"Network Access"**
2. 点击 **"Add IP Address"**
3. 选择 **"Allow Access from Anywhere"**
   ```
   IP Address: 0.0.0.0/0
   ```
   ⚠️ 生产环境中应该限制 IP，但开发测试可以这样设置
4. 点击 **"Confirm"**

### 1.5 获取连接字符串

1. 返回到 **"Database"** 页面
2. 点击您的集群的 **"Connect"** 按钮
3. 选择 **"Connect your application"**
4. Driver: 选择 **"Node.js"**，Version: **5.5 or later**
5. 复制连接字符串，看起来像这样：
   ```
   mongodb+srv://admin:<password>@cluster0.xxxxx.mongodb.net/?retryWrites=true&w=majority
   ```
6. **重要**：将 `<password>` 替换为您在步骤 1.3 创建的实际密码
7. **建议**：在末尾的 `/?` 之间添加数据库名 `llama-io`：
   ```
   mongodb+srv://admin:你的密码@cluster0.xxxxx.mongodb.net/llama-io?retryWrites=true&w=majority
   ```

✅ MongoDB Atlas 设置完成！

---

## 步骤 2: 配置项目

### 2.1 检查依赖是否已安装

在项目目录运行：
```bash
ls node_modules
```

如果看到很多文件夹，说明依赖已安装。如果没有，运行：
```bash
npm install
```

### 2.2 创建 .env 文件

在终端运行以下命令（一条一条执行）：

```bash
cat > .env << 'EOF'
MONGO_URI=在这里粘贴您的连接字符串
PORT=3000
EOF
```

**或者手动创建**：

1. 在项目根目录创建文件 `.env`
2. 添加以下内容：
   ```
   MONGO_URI=mongodb+srv://admin:你的密码@cluster0.xxxxx.mongodb.net/llama-io?retryWrites=true&w=majority
   PORT=3000
   ```

⚠️ **确保**：
- 密码中没有 `<` 和 `>` 符号
- 连接字符串是一行，没有换行
- 添加了数据库名 `llama-io`

### 2.3 验证 .env 文件

运行以下命令检查：
```bash
cat .env
```

应该看到：
```
MONGO_URI=mongodb+srv://...
PORT=3000
```

✅ 项目配置完成！

---

## 步骤 3: 启动服务器

### 3.1 启动服务器

在终端运行：
```bash
npm run dev
```

### 3.2 检查输出

如果成功，您会看到：
```
MongoDB connected
API running on http://localhost:3000
```

✅ **成功！** 服务器正在运行

❌ **如果看到错误**，请查看下面的故障排除部分。

---

## 步骤 4: 验证 API

### 4.1 保持服务器运行

⚠️ **不要关闭** 当前终端窗口

### 4.2 打开新终端

按 `Cmd + T`（Mac）或 `Ctrl + Shift + T`（Windows/Linux）打开新标签页

### 4.3 运行快速测试

```bash
cd /Users/shuwei/UiucProjects/cs409/mp3
./quick-test.sh
```

您应该看到测试结果和 API 响应。

### 4.4 手动测试（可选）

**测试 1: 创建用户**
```bash
curl -X POST http://localhost:3000/api/users \
  -H "Content-Type: application/json" \
  -d '{"name":"测试用户","email":"test@example.com"}'
```

应该返回：
```json
{
  "message": "Created",
  "data": {
    "_id": "...",
    "name": "测试用户",
    "email": "test@example.com",
    ...
  }
}
```

**测试 2: 获取所有用户**
```bash
curl http://localhost:3000/api/users
```

**测试 3: 创建任务**
```bash
curl -X POST http://localhost:3000/api/tasks \
  -H "Content-Type: application/json" \
  -d '{"name":"测试任务","deadline":"2025-12-31T23:59:59Z"}'
```

**测试 4: 获取任务计数**
```bash
curl "http://localhost:3000/api/tasks?count=true"
```

✅ 如果以上命令都返回正确的 JSON 响应，API 工作正常！

---

## 🐛 故障排除

### 错误 1: "MONGO_URI is not set"
**原因**: `.env` 文件不存在或格式错误

**解决方法**:
```bash
# 检查文件是否存在
ls -la .env

# 查看文件内容
cat .env

# 确保第一行是 MONGO_URI=...（没有空格）
```

---

### 错误 2: "MongoServerError: bad auth"
**原因**: 用户名或密码错误

**解决方法**:
1. 回到 MongoDB Atlas
2. Database Access → 编辑或重新创建用户
3. 确保密码复制正确
4. 更新 `.env` 文件中的密码

---

### 错误 3: "Could not connect to any servers"
**原因**: 网络访问未配置

**解决方法**:
1. 回到 MongoDB Atlas
2. Network Access → 确保有 `0.0.0.0/0` 条目
3. 等待 1-2 分钟让更改生效

---

### 错误 4: "Cannot find module"
**原因**: 依赖未安装

**解决方法**:
```bash
rm -rf node_modules package-lock.json
npm install
```

---

### 错误 5: curl 命令不工作
**原因**: 命令在 Windows 上可能需要调整

**Windows PowerShell 用户**，使用：
```powershell
Invoke-WebRequest -Uri http://localhost:3000/api/users -Method GET
```

或者安装 Git Bash 使用 curl

---

## 📊 验证数据库

### 在 MongoDB Atlas 中查看数据

1. 登录 MongoDB Atlas
2. 点击 **"Database"**
3. 点击您集群的 **"Browse Collections"**
4. 您应该看到 `llama-io` 数据库
5. 展开可以看到 `users` 和 `tasks` 集合
6. 点击集合可以看到您创建的数据

---

## ✅ 完整检查清单

- [ ] MongoDB Atlas 账号已创建
- [ ] 免费集群已创建（M0 Sandbox）
- [ ] 数据库用户已创建（admin + 密码）
- [ ] 网络访问已配置（0.0.0.0/0）
- [ ] 连接字符串已获取
- [ ] .env 文件已创建，包含正确的 MONGO_URI
- [ ] npm install 已运行
- [ ] npm run dev 成功启动
- [ ] 看到 "MongoDB connected" 消息
- [ ] 可以创建用户（POST /api/users）
- [ ] 可以创建任务（POST /api/tasks）
- [ ] 可以查询数据（GET 端点）

---

## 🎉 下一步

验证成功后：

1. **阅读 API 文档**: `cat README.md`
2. **运行完整测试**: `./test-api.sh`
3. **查看验证指南**: `cat VERIFICATION.md`
4. **开始使用 API**: 参考 README 中的示例

---

## 📞 需要帮助？

如果遇到问题：

1. 检查服务器终端的错误消息
2. 确保 .env 文件格式正确
3. 确保 MongoDB Atlas 设置完整
4. 重新运行故障排除步骤

---

**祝您设置顺利！** 🚀

