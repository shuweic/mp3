#!/bin/bash

# 测试 Llama.io REST API
# 确保服务器正在运行在 http://localhost:3000

API_URL="http://localhost:3000/api"

echo "🧪 开始测试 Llama.io API"
echo "=================================="
echo ""

# 颜色定义
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 测试计数器
TESTS_PASSED=0
TESTS_FAILED=0

# 测试函数
test_request() {
  local name=$1
  local method=$2
  local url=$3
  local data=$4
  
  echo -e "${BLUE}测试: ${name}${NC}"
  
  if [ -z "$data" ]; then
    response=$(curl -s -X $method "$url" -H "Content-Type: application/json")
  else
    response=$(curl -s -X $method "$url" -H "Content-Type: application/json" -d "$data")
  fi
  
  echo "响应: $response" | head -c 200
  echo ""
  
  if [[ $response == *"message"* ]]; then
    echo -e "${GREEN}✓ 通过${NC}"
    ((TESTS_PASSED++))
  else
    echo -e "${RED}✗ 失败${NC}"
    ((TESTS_FAILED++))
  fi
  echo ""
}

# 1. 测试创建用户
echo "📝 测试用户端点"
echo "--------------------------------"
test_request "创建用户 #1" POST "$API_URL/users" \
  '{"name":"Alice Wang","email":"alice@test.com"}'

test_request "创建用户 #2" POST "$API_URL/users" \
  '{"name":"Bob Chen","email":"bob@test.com"}'

test_request "创建用户 #3" POST "$API_URL/users" \
  '{"name":"Charlie Li","email":"charlie@test.com"}'

# 2. 测试获取所有用户
test_request "获取所有用户" GET "$API_URL/users"

# 3. 测试查询参数
test_request "用户查询 - 排序" GET "$API_URL/users?sort={\"name\":1}"

test_request "用户查询 - 字段选择" GET "$API_URL/users?select={\"name\":1,\"email\":1}"

test_request "用户查询 - 分页" GET "$API_URL/users?skip=1&limit=2"

test_request "用户计数" GET "$API_URL/users?count=true"

# 4. 保存第一个用户ID（需要手动设置）
echo "⚠️  请从上面的响应中复制第一个用户的 _id，然后继续..."
read -p "输入用户 ID: " USER_ID

if [ ! -z "$USER_ID" ]; then
  test_request "获取单个用户" GET "$API_URL/users/$USER_ID"
fi

echo ""
echo "📋 测试任务端点"
echo "--------------------------------"

# 5. 创建任务
test_request "创建任务 #1 (无分配)" POST "$API_URL/tasks" \
  '{"name":"完成项目报告","description":"写一个详细的报告","deadline":"2025-12-31T23:59:59Z"}'

test_request "创建任务 #2 (无分配)" POST "$API_URL/tasks" \
  '{"name":"代码审查","deadline":"2025-11-15T10:00:00Z","completed":false}'

if [ ! -z "$USER_ID" ]; then
  test_request "创建任务 #3 (分配给用户)" POST "$API_URL/tasks" \
    "{\"name\":\"团队会议\",\"description\":\"讨论Q4目标\",\"deadline\":\"2025-11-01T14:00:00Z\",\"assignedUser\":\"$USER_ID\"}"
fi

# 6. 测试获取所有任务
test_request "获取所有任务" GET "$API_URL/tasks"

# 7. 测试任务查询
test_request "任务查询 - 过滤未完成" GET "$API_URL/tasks?where={\"completed\":false}"

test_request "任务查询 - 排序按截止日期" GET "$API_URL/tasks?sort={\"deadline\":1}"

test_request "任务查询 - 限制结果" GET "$API_URL/tasks?limit=2"

test_request "任务计数" GET "$API_URL/tasks?count=true"

# 8. 获取任务ID
echo ""
read -p "输入一个任务 ID 进行更新/删除测试: " TASK_ID

if [ ! -z "$TASK_ID" ]; then
  test_request "获取单个任务" GET "$API_URL/tasks/$TASK_ID"
  
  if [ ! -z "$USER_ID" ]; then
    test_request "更新任务 (PUT)" PUT "$API_URL/tasks/$TASK_ID" \
      "{\"name\":\"更新的任务\",\"description\":\"新描述\",\"deadline\":\"2025-12-25T00:00:00Z\",\"completed\":true,\"assignedUser\":\"$USER_ID\"}"
  fi
fi

# 9. 测试错误情况
echo ""
echo "🚨 测试错误处理"
echo "--------------------------------"

test_request "创建用户 - 缺少必填字段" POST "$API_URL/users" \
  '{"name":"Test"}'

test_request "创建任务 - 缺少必填字段" POST "$API_URL/tasks" \
  '{"name":"Task without deadline"}'

test_request "获取不存在的用户" GET "$API_URL/users/000000000000000000000000"

test_request "重复邮箱" POST "$API_URL/users" \
  '{"name":"Alice Wang","email":"alice@test.com"}'

# 10. 总结
echo ""
echo "=================================="
echo "📊 测试总结"
echo "=================================="
echo -e "${GREEN}通过: $TESTS_PASSED${NC}"
echo -e "${RED}失败: $TESTS_FAILED${NC}"
echo ""

if [ $TESTS_FAILED -eq 0 ]; then
  echo -e "${GREEN}🎉 所有测试通过！${NC}"
else
  echo -e "${RED}⚠️  部分测试失败，请检查服务器日志${NC}"
fi

