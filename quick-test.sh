#!/bin/bash

# Quick verification script - Test basic functionality
# Usage: ./quick-test.sh

API_URL="http://localhost:3000/api"

echo "🚀 Quick Test - Llama.io API"
echo ""

# Check if server is running
echo "1️⃣ Checking server status..."
if curl -s "$API_URL/users" > /dev/null 2>&1; then
    echo "✅ Server is running"
else
    echo "❌ Server is not running. Please start with: npm run dev"
    exit 1
fi
echo ""

# Create test user
echo "2️⃣ Creating test user..."
USER_RESPONSE=$(curl -s -X POST "$API_URL/users" \
  -H "Content-Type: application/json" \
  -d '{"name":"Test User","email":"test@example.com"}')
echo "$USER_RESPONSE" | python3 -m json.tool 2>/dev/null || echo "$USER_RESPONSE"
USER_ID=$(echo "$USER_RESPONSE" | grep -o '"_id":"[^"]*"' | head -1 | cut -d'"' -f4)
echo "User ID: $USER_ID"
echo ""

# Create test task
echo "3️⃣ Creating test task..."
TASK_RESPONSE=$(curl -s -X POST "$API_URL/tasks" \
  -H "Content-Type: application/json" \
  -d "{\"name\":\"Test Task\",\"description\":\"This is a test task\",\"deadline\":\"2025-12-31T23:59:59Z\",\"assignedUser\":\"$USER_ID\"}")
echo "$TASK_RESPONSE" | python3 -m json.tool 2>/dev/null || echo "$TASK_RESPONSE"
TASK_ID=$(echo "$TASK_RESPONSE" | grep -o '"_id":"[^"]*"' | head -1 | cut -d'"' -f4)
echo "Task ID: $TASK_ID"
echo ""

# Verify user's pendingTasks
echo "4️⃣ Verifying user's pendingTasks..."
curl -s "$API_URL/users/$USER_ID" | python3 -m json.tool 2>/dev/null
echo ""

# Get all tasks
echo "5️⃣ Getting all tasks (limited to 3)..."
curl -s "$API_URL/tasks?limit=3" | python3 -m json.tool 2>/dev/null
echo ""

# Test query functionality
echo "6️⃣ Testing query - incomplete tasks..."
curl -s "$API_URL/tasks?where={\"completed\":false}&sort={\"deadline\":1}" | python3 -m json.tool 2>/dev/null
echo ""

# Test count
echo "7️⃣ Testing count functionality..."
echo "Total users:"
curl -s "$API_URL/users?count=true" | python3 -m json.tool 2>/dev/null
echo ""
echo "Total tasks:"
curl -s "$API_URL/tasks?count=true" | python3 -m json.tool 2>/dev/null
echo ""

# Test error handling
echo "8️⃣ Testing error handling - missing required field..."
curl -s -X POST "$API_URL/users" \
  -H "Content-Type: application/json" \
  -d '{"name":"User Without Email"}' | python3 -m json.tool 2>/dev/null
echo ""

echo "9️⃣ Testing error handling - duplicate email..."
curl -s -X POST "$API_URL/users" \
  -H "Content-Type: application/json" \
  -d '{"name":"Duplicate User","email":"test@example.com"}' | python3 -m json.tool 2>/dev/null
echo ""

echo "✅ Quick verification complete!"
echo ""
echo "💡 Tips:"
echo "   - For detailed tests: ./test-api.sh"
echo "   - Clean test data: python3 dbClean.py -u localhost -p 3000"
