# 🚀 部署到 Render 指南

完整的步骤，将您的 Llama.io API 部署到 Render 云平台。

---

## 📋 前提条件

- ✅ MongoDB Atlas 已设置并配置（允许从任何地方访问）
- ✅ Git 仓库已创建（GitHub）
- ✅ 代码已推送到 GitHub
- ✅ 本地测试通过

---

## 第一步：准备 Git 仓库

### 1.1 初始化 Git（如果还没有）

```bash
cd /Users/shuwei/UiucProjects/cs409/mp3
git init
git add .
git commit -m "Initial commit: Llama.io REST API"
```

### 1.2 创建 GitHub 仓库

1. 访问 https://github.com/new
2. 仓库名称：`cs409-mp3` 或 `llama-io-api`
3. 设置为 **Public**（方便教授查看）
4. **不要**勾选 "Initialize with README"
5. 点击 **Create repository**

### 1.3 推送到 GitHub

```bash
# 替换为您的 GitHub 用户名和仓库名
git remote add origin https://github.com/YOUR_USERNAME/cs409-mp3.git
git branch -M main
git push -u origin main
```

### 1.4 验证 .gitignore

⚠️ **重要**: 确保 `.env` 文件**没有**被推送到 GitHub

```bash
# 检查 .gitignore 内容
cat .gitignore
```

应该看到：
```
node_modules
.env
```

✅ `.env` **必须在第 2 行且没有被注释**（没有 `#` 符号）

```bash
# 验证 .env 没有被推送
git status
# 不应该看到 .env 在待提交文件中
```

---

## 第二步：在 Render 创建账号

### 2.1 注册 Render

1. 访问 https://render.com
2. 点击 **Get Started** 或 **Sign Up**
3. 使用 **GitHub** 账号登录（推荐）
4. 授权 Render 访问您的 GitHub

---

## 第三步：在 Render 创建 Web Service

### 3.1 创建新服务

1. 登录 Render 后，点击 **Dashboard**
2. 点击 **New +** 按钮
3. 选择 **Web Service**

### 3.2 连接 GitHub 仓库

1. 找到您的仓库（如 `cs409-mp3`）
2. 点击 **Connect**

如果看不到仓库：
- 点击 **Configure GitHub account**
- 授权 Render 访问该仓库
- 刷新页面

### 3.3 配置 Web Service

填写以下信息：

#### 基本设置
- **Name**: `llama-io-api` 或 `cs409-mp3-api`（将成为 URL 的一部分）
- **Region**: 选择 **Oregon (US West)** 或最近的区域
- **Branch**: `main`
- **Root Directory**: 留空
- **Runtime**: **Node**

#### 构建和部署设置
- **Build Command**: `npm install`
- **Start Command**: `npm run dev`

#### 计划
- **Instance Type**: 选择 **Free**

### 3.4 添加环境变量

在 **Environment Variables** 部分，点击 **Add Environment Variable**

添加以下变量：

**变量 1:**
- **Key**: `MONGO_URI`
- **Value**: 您的 MongoDB Atlas 连接字符串
  ```
  mongodb+srv://shuweic227_db_user:Rn6QL8rbyYa8SJyC@cluster0.kbr9vdt.mongodb.net/llama-io?retryWrites=true&w=majority&appName=Cluster0
  ```

**变量 2:**
- **Key**: `PORT`
- **Value**: `3000`

⚠️ **注意**: 不要使用 `.env` 文件中的值，直接在 Render 界面输入！

### 3.5 创建服务

1. 确认所有设置正确
2. 点击 **Create Web Service**
3. 等待部署（约 3-5 分钟）

---

## 第四步：验证部署

### 4.1 检查部署状态

1. 在 Render Dashboard，查看您的服务
2. 等待状态变为 **Live** (绿色)
3. 如果显示 **Deploy failed**，点击查看日志

### 4.2 获取 API URL

部署成功后，您会看到：
```
Your service is live at https://llama-io-api.onrender.com
```

记下这个 URL！

### 4.3 测试 API

在终端运行：

```bash
# 替换为您的 Render URL
API_URL="https://llama-io-api.onrender.com"

# 测试连接
curl $API_URL/api/users

# 创建用户
curl -X POST $API_URL/api/users \
  -H "Content-Type: application/json" \
  -d '{"name":"Test User","email":"test@render.com"}'

# 获取所有用户
curl $API_URL/api/users
```

如果返回 JSON 响应，说明部署成功！🎉

---

## 第五步：填充数据库

### 5.1 使用 dbFill.py 脚本

```bash
# 使用您的 Render URL（不包括 https:// 和末尾斜杠）
python3 database_scripts/dbFill.py -u "llama-io-api.onrender.com" -p 443 -n 20 -t 100
```

⚠️ **注意**: 
- Render 使用 HTTPS，端口是 443
- URL 格式：`your-app-name.onrender.com`（不包括 `https://`）

如果脚本不支持 HTTPS，直接在 MongoDB Atlas 填充数据。

### 5.2 验证数据

```bash
# 检查用户数量
curl "https://llama-io-api.onrender.com/api/users?count=true"

# 检查任务数量
curl "https://llama-io-api.onrender.com/api/tasks?count=true"
```

应该看到至少 20 个用户和 100 个任务。

---

## 第六步：提交作业

### 6.1 准备提交信息

您需要提交：

1. **GitHub 仓库 URL**: 
   ```
   https://github.com/YOUR_USERNAME/cs409-mp3
   ```

2. **Render 部署 URL**: 
   ```
   https://llama-io-api.onrender.com/api
   ```

3. **MongoDB Atlas 连接信息**（如果需要）

### 6.2 验证检查清单

- [ ] GitHub 仓库是 Public
- [ ] `.gitignore` 文件存在且包含 `.env`
- [ ] `.env` 文件**没有**被推送到 GitHub
- [ ] Render 部署成功，状态为 Live
- [ ] API 可以通过 Render URL 访问
- [ ] 数据库有至少 20 个用户
- [ ] 数据库有至少 100 个任务
- [ ] 约 50% 的任务已完成
- [ ] MongoDB Atlas 允许从任何地方访问 (0.0.0.0/0)

---

## 🐛 常见问题和解决方案

### 问题 1: 部署失败 - "Module not found"

**原因**: `package.json` 中缺少依赖

**解决**:
1. 确保 `package.json` 中有所有依赖
2. 在 Render 中触发 **Manual Deploy**

---

### 问题 2: 部署失败 - "MONGO_URI is not set"

**原因**: 环境变量未设置

**解决**:
1. 在 Render Dashboard → 您的服务 → **Environment**
2. 确保 `MONGO_URI` 和 `PORT` 已设置
3. 点击 **Save Changes**（会自动重新部署）

---

### 问题 3: API 返回 500 错误

**原因**: MongoDB 连接失败

**解决**:
1. 检查 MongoDB Atlas **Network Access**
2. 确保添加了 `0.0.0.0/0`（允许从任何地方访问）
3. 检查连接字符串是否正确
4. 在 Render **Logs** 中查看详细错误

---

### 问题 4: Render 服务自动睡眠

**原因**: Free tier 在 15 分钟无活动后会睡眠

**影响**: 首次请求可能需要 30-60 秒唤醒

**解决**: 
- 这是正常的，不影响评分
- 也可以升级到付费计划（$7/月）保持活跃

---

### 问题 5: dbFill.py 无法连接 Render

**原因**: 脚本可能不支持 HTTPS

**解决方案 1**: 修改脚本支持 HTTPS

**解决方案 2**: 使用 Postman 或 curl 手动创建数据

**解决方案 3**: 在本地运行 API，用 dbFill.py 填充，数据会同步到 Atlas

---

## 📊 部署后测试

### 完整的 API 测试

```bash
# 设置您的 Render URL
export API_URL="https://llama-io-api.onrender.com/api"

# 1. 创建用户
curl -X POST $API_URL/users \
  -H "Content-Type: application/json" \
  -d '{"name":"Alice","email":"alice@test.com"}'

# 2. 获取所有用户
curl $API_URL/users

# 3. 创建任务
curl -X POST $API_URL/tasks \
  -H "Content-Type: application/json" \
  -d '{"name":"Test Task","deadline":"2025-12-31T23:59:59Z"}'

# 4. 查询未完成任务
curl "$API_URL/tasks?where={\"completed\":false}"

# 5. 用户计数
curl "$API_URL/users?count=true"

# 6. 任务计数
curl "$API_URL/tasks?count=true"
```

所有请求应该返回正确的 JSON 响应。

---

## 🎯 最终检查

部署完成后，确保：

1. ✅ **GitHub**:
   - 仓库是 public
   - `.env` 没有被提交
   - `.gitignore` 正确配置

2. ✅ **Render**:
   - 服务状态是 Live
   - 可以通过 URL 访问 API
   - 所有端点工作正常

3. ✅ **MongoDB Atlas**:
   - 至少 20 个用户
   - 至少 100 个任务
   - Network Access 配置为 0.0.0.0/0

4. ✅ **功能测试**:
   - 所有 CRUD 操作工作
   - 查询参数工作
   - 错误处理正确
   - 双向引用正确

---

## 📝 提交模板

在提交作业时，使用以下模板：

```
GitHub Repository: https://github.com/YOUR_USERNAME/cs409-mp3
Render API URL: https://llama-io-api.onrender.com/api
MongoDB: Hosted on MongoDB Atlas

Test Credentials (if needed):
- Database has 20+ users
- Database has 100+ tasks
- Network access: 0.0.0.0/0 (Allow from anywhere)

Notes:
- All endpoints implemented and tested
- Query parameters working (where, sort, select, skip, limit, count)
- Two-way reference between User and Task implemented
- Error handling with appropriate HTTP status codes

Source files:
- package.json: Project configuration
- src/server.js: Entry point
- src/app.js: Express configuration
- src/models/: User and Task schemas
- src/controllers/: Business logic
- src/routes/: API routes
- src/middleware/: Validation and error handling
```

---

## 🎉 完成！

您的 API 现在已经部署到 Render 并可以被访问和评分！

**最终 URL 示例**:
- API Base: `https://llama-io-api.onrender.com/api`
- Users: `https://llama-io-api.onrender.com/api/users`
- Tasks: `https://llama-io-api.onrender.com/api/tasks`

**祝您取得好成绩！** 🎓

---

**提示**: 保存 Render URL，您可能需要在以后访问或调试。

