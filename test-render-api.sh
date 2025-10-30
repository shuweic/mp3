#!/bin/bash

# 测试 Render 部署的 API
API_URL="https://cs409-mp3-api.onrender.com/api"

echo "🧪 CS409 MP3 API 完整测试"
echo "================================"
echo "API: $API_URL"
echo ""

# 测试计数器
PASS=0
FAIL=0

# 测试函数
test_endpoint() {
    local name=$1
    local url=$2
    local expected=$3
    
    echo "测试: $name"
    response=$(curl -s "$url")
    
    if echo "$response" | grep -q "$expected"; then
        echo "✅ 通过"
        ((PASS++))
    else
        echo "❌ 失败"
        echo "响应: $response"
        ((FAIL++))
    fi
    echo ""
}

# 基础端点测试
echo "📌 基础端点测试"
echo "--------------------------------"
test_endpoint "获取用户列表" "$API_URL/users" '"message":"OK"'
test_endpoint "获取任务列表" "$API_URL/tasks" '"message":"OK"'
test_endpoint "用户计数" "$API_URL/users?count=true" '"data":'
test_endpoint "任务计数" "$API_URL/tasks?count=true" '"data":'

# 查询参数测试
echo "🔍 查询参数测试"
echo "--------------------------------"
test_endpoint "where 过滤" "$API_URL/tasks?where={\"completed\":false}&limit=1" '"completed":false'
test_endpoint "sort 排序" "$API_URL/users?sort={\"name\":1}&limit=1" '"name":'
test_endpoint "limit 限制" "$API_URL/users?limit=1" '"_id":'

# POST 测试
echo "➕ 创建资源测试"
echo "--------------------------------"
echo "测试: 创建新用户"
response=$(curl -s -X POST "$API_URL/users" \
  -H "Content-Type: application/json" \
  -d "{\"name\":\"Test User $(date +%s)\",\"email\":\"test$(date +%s)@render.com\"}")

if echo "$response" | grep -q '"message":"Created"'; then
    echo "✅ 通过"
    ((PASS++))
    USER_ID=$(echo "$response" | grep -o '"_id":"[^"]*"' | head -1 | cut -d'"' -f4)
    echo "创建的用户ID: $USER_ID"
else
    echo "❌ 失败"
    echo "响应: $response"
    ((FAIL++))
fi
echo ""

# 获取单个资源测试
if [ ! -z "$USER_ID" ]; then
    echo "🔎 单个资源测试"
    echo "--------------------------------"
    test_endpoint "获取单个用户" "$API_URL/users/$USER_ID" '"_id":"'$USER_ID'"'
fi

# 总结
echo "================================"
echo "📊 测试总结"
echo "================================"
echo "✅ 通过: $PASS"
echo "❌ 失败: $FAIL"
echo ""

if [ $FAIL -eq 0 ]; then
    echo "🎉 所有测试通过！API 工作正常！"
    exit 0
else
    echo "⚠️  有测试失败，请检查 API"
    exit 1
fi

