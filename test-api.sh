#!/bin/bash

# Test Llama.io REST API
# Make sure server is running at http://localhost:3000

API_URL="http://localhost:3000/api"

echo "🧪 Starting Llama.io API Test"
echo "=================================="
echo ""

# Color definitions
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Test counters
TESTS_PASSED=0
TESTS_FAILED=0

# Test function
test_request() {
  local name=$1
  local method=$2
  local url=$3
  local data=$4
  
  echo -e "${BLUE}Test: ${name}${NC}"
  
  if [ -z "$data" ]; then
    response=$(curl -s -X $method "$url" -H "Content-Type: application/json")
  else
    response=$(curl -s -X $method "$url" -H "Content-Type: application/json" -d "$data")
  fi
  
  echo "Response: $response" | head -c 200
  echo ""
  
  if [[ $response == *"message"* ]]; then
    echo -e "${GREEN}✓ Passed${NC}"
    ((TESTS_PASSED++))
  else
    echo -e "${RED}✗ Failed${NC}"
    ((TESTS_FAILED++))
  fi
  echo ""
}

# 1. Test create users
echo "📝 Testing User Endpoints"
echo "--------------------------------"
test_request "Create User #1" POST "$API_URL/users" \
  '{"name":"Alice Wang","email":"alice@test.com"}'

test_request "Create User #2" POST "$API_URL/users" \
  '{"name":"Bob Chen","email":"bob@test.com"}'

test_request "Create User #3" POST "$API_URL/users" \
  '{"name":"Charlie Li","email":"charlie@test.com"}'

# 2. Test get all users
test_request "Get All Users" GET "$API_URL/users"

# 3. Test query parameters
test_request "User Query - Sort" GET "$API_URL/users?sort={\"name\":1}"

test_request "User Query - Field Selection" GET "$API_URL/users?select={\"name\":1,\"email\":1}"

test_request "User Query - Pagination" GET "$API_URL/users?skip=1&limit=2"

test_request "User Count" GET "$API_URL/users?count=true"

# 4. Save first user ID (manual input required)
echo "⚠️  Please copy the first user's _id from the responses above..."
read -p "Enter User ID: " USER_ID

if [ ! -z "$USER_ID" ]; then
  test_request "Get Single User" GET "$API_URL/users/$USER_ID"
fi

echo ""
echo "📋 Testing Task Endpoints"
echo "--------------------------------"

# 5. Create tasks
test_request "Create Task #1 (Unassigned)" POST "$API_URL/tasks" \
  '{"name":"Complete project report","description":"Write a detailed report","deadline":"2025-12-31T23:59:59Z"}'

test_request "Create Task #2 (Unassigned)" POST "$API_URL/tasks" \
  '{"name":"Code review","deadline":"2025-11-15T10:00:00Z","completed":false}'

if [ ! -z "$USER_ID" ]; then
  test_request "Create Task #3 (Assigned to User)" POST "$API_URL/tasks" \
    "{\"name\":\"Team meeting\",\"description\":\"Discuss Q4 goals\",\"deadline\":\"2025-11-01T14:00:00Z\",\"assignedUser\":\"$USER_ID\"}"
fi

# 6. Test get all tasks
test_request "Get All Tasks" GET "$API_URL/tasks"

# 7. Test task queries
test_request "Task Query - Filter Incomplete" GET "$API_URL/tasks?where={\"completed\":false}"

test_request "Task Query - Sort by Deadline" GET "$API_URL/tasks?sort={\"deadline\":1}"

test_request "Task Query - Limit Results" GET "$API_URL/tasks?limit=2"

test_request "Task Count" GET "$API_URL/tasks?count=true"

# 8. Get task ID
echo ""
read -p "Enter a Task ID for update/delete tests: " TASK_ID

if [ ! -z "$TASK_ID" ]; then
  test_request "Get Single Task" GET "$API_URL/tasks/$TASK_ID"
  
  if [ ! -z "$USER_ID" ]; then
    test_request "Update Task (PUT)" PUT "$API_URL/tasks/$TASK_ID" \
      "{\"name\":\"Updated Task\",\"description\":\"New description\",\"deadline\":\"2025-12-25T00:00:00Z\",\"completed\":true,\"assignedUser\":\"$USER_ID\"}"
  fi
fi

# 9. Test error cases
echo ""
echo "🚨 Testing Error Handling"
echo "--------------------------------"

test_request "Create User - Missing Required Field" POST "$API_URL/users" \
  '{"name":"Test"}'

test_request "Create Task - Missing Required Field" POST "$API_URL/tasks" \
  '{"name":"Task without deadline"}'

test_request "Get Non-existent User" GET "$API_URL/users/000000000000000000000000"

test_request "Duplicate Email" POST "$API_URL/users" \
  '{"name":"Alice Wang","email":"alice@test.com"}'

# 10. Summary
echo ""
echo "=================================="
echo "📊 Test Summary"
echo "=================================="
echo -e "${GREEN}Passed: $TESTS_PASSED${NC}"
echo -e "${RED}Failed: $TESTS_FAILED${NC}"
echo ""

if [ $TESTS_FAILED -eq 0 ]; then
  echo -e "${GREEN}🎉 All tests passed!${NC}"
else
  echo -e "${RED}⚠️  Some tests failed, please check server logs${NC}"
fi
