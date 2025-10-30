#!/bin/bash

# Test Render deployed API
API_URL="https://cs409-mp3-api.onrender.com/api"

echo "🧪 CS409 MP3 API Full Test"
echo "================================"
echo "API: $API_URL"
echo ""

# Test counters
PASS=0
FAIL=0

# Test function
test_endpoint() {
    local name=$1
    local url=$2
    local expected=$3
    
    echo "Testing: $name"
    response=$(curl -s "$url")
    
    if echo "$response" | grep -q "$expected"; then
        echo "✅ Pass"
        ((PASS++))
    else
        echo "❌ Fail"
        echo "Response: $response"
        ((FAIL++))
    fi
    echo ""
}

# Basic endpoint tests
echo "📌 Basic Endpoint Tests"
echo "--------------------------------"
test_endpoint "Get user list" "$API_URL/users" '"message":"OK"'
test_endpoint "Get task list" "$API_URL/tasks" '"message":"OK"'
test_endpoint "User count" "$API_URL/users?count=true" '"data":'
test_endpoint "Task count" "$API_URL/tasks?count=true" '"data":'

# Query parameter tests
echo "🔍 Query Parameter Tests"
echo "--------------------------------"
test_endpoint "where filter" "$API_URL/tasks?where={\"completed\":false}&limit=1" '"completed":false'
test_endpoint "sort ordering" "$API_URL/users?sort={\"name\":1}&limit=1" '"name":'
test_endpoint "limit records" "$API_URL/users?limit=1" '"_id":'

# POST test
echo "➕ Resource Creation Test"
echo "--------------------------------"
echo "Testing: Create new user"
response=$(curl -s -X POST "$API_URL/users" \
  -H "Content-Type: application/json" \
  -d "{\"name\":\"Test User $(date +%s)\",\"email\":\"test$(date +%s)@render.com\"}")

if echo "$response" | grep -q '"message":"Created"'; then
    echo "✅ Pass"
    ((PASS++))
    USER_ID=$(echo "$response" | grep -o '"_id":"[^"]*"' | head -1 | cut -d'"' -f4)
    echo "Created user ID: $USER_ID"
else
    echo "❌ Fail"
    echo "Response: $response"
    ((FAIL++))
fi
echo ""

# Single resource test
if [ ! -z "$USER_ID" ]; then
    echo "🔎 Single Resource Test"
    echo "--------------------------------"
    test_endpoint "Get single user" "$API_URL/users/$USER_ID" '"_id":"'$USER_ID'"'
fi

# Summary
echo "================================"
echo "📊 Test Summary"
echo "================================"
echo "✅ Passed: $PASS"
echo "❌ Failed: $FAIL"
echo ""

if [ $FAIL -eq 0 ]; then
    echo "🎉 All tests passed! API is working properly!"
    exit 0
else
    echo "⚠️  Some tests failed, please check the API"
    exit 1
fi
