#!/bin/bash

# 快速验证脚本 - 测试基本功能
# 使用方法: ./quick-test.sh

API_URL="http://localhost:3000/api"

echo "🚀 快速验证 Llama.io API"
echo ""

# 检查服务器是否运行
echo "1️⃣ 检查服务器状态..."
if curl -s "$API_URL/users" > /dev/null 2>&1; then
    echo "✅ 服务器正在运行"
else
    echo "❌ 服务器未运行，请先运行: npm run dev"
    exit 1
fi
echo ""

# 创建测试用户
echo "2️⃣ 创建测试用户..."
USER_RESPONSE=$(curl -s -X POST "$API_URL/users" \
  -H "Content-Type: application/json" \
  -d '{"name":"测试用户","email":"test@example.com"}')
echo "$USER_RESPONSE" | python3 -m json.tool 2>/dev/null || echo "$USER_RESPONSE"
USER_ID=$(echo "$USER_RESPONSE" | grep -o '"_id":"[^"]*"' | head -1 | cut -d'"' -f4)
echo "用户 ID: $USER_ID"
echo ""

# 创建测试任务
echo "3️⃣ 创建测试任务..."
TASK_RESPONSE=$(curl -s -X POST "$API_URL/tasks" \
  -H "Content-Type: application/json" \
  -d "{\"name\":\"测试任务\",\"description\":\"这是一个测试任务\",\"deadline\":\"2025-12-31T23:59:59Z\",\"assignedUser\":\"$USER_ID\"}")
echo "$TASK_RESPONSE" | python3 -m json.tool 2>/dev/null || echo "$TASK_RESPONSE"
TASK_ID=$(echo "$TASK_RESPONSE" | grep -o '"_id":"[^"]*"' | head -1 | cut -d'"' -f4)
echo "任务 ID: $TASK_ID"
echo ""

# 验证用户的 pendingTasks
echo "4️⃣ 验证用户的 pendingTasks..."
curl -s "$API_URL/users/$USER_ID" | python3 -m json.tool 2>/dev/null
echo ""

# 获取所有任务
echo "5️⃣ 获取所有任务（限制3个）..."
curl -s "$API_URL/tasks?limit=3" | python3 -m json.tool 2>/dev/null
echo ""

# 测试查询功能
echo "6️⃣ 测试查询 - 未完成的任务..."
curl -s "$API_URL/tasks?where={\"completed\":false}&sort={\"deadline\":1}" | python3 -m json.tool 2>/dev/null
echo ""

# 测试计数
echo "7️⃣ 测试计数功能..."
echo "用户总数:"
curl -s "$API_URL/users?count=true" | python3 -m json.tool 2>/dev/null
echo ""
echo "任务总数:"
curl -s "$API_URL/tasks?count=true" | python3 -m json.tool 2>/dev/null
echo ""

# 测试错误处理
echo "8️⃣ 测试错误处理 - 缺少必填字段..."
curl -s -X POST "$API_URL/users" \
  -H "Content-Type: application/json" \
  -d '{"name":"无邮箱用户"}' | python3 -m json.tool 2>/dev/null
echo ""

echo "9️⃣ 测试错误处理 - 重复邮箱..."
curl -s -X POST "$API_URL/users" \
  -H "Content-Type: application/json" \
  -d '{"name":"重复用户","email":"test@example.com"}' | python3 -m json.tool 2>/dev/null
echo ""

echo "✅ 快速验证完成！"
echo ""
echo "💡 提示:"
echo "   - 查看详细测试: ./test-api.sh"
echo "   - 查看完整指南: cat VERIFICATION.md"
echo "   - 清理测试数据: python3 dbClean.py -u localhost -p 3000"

