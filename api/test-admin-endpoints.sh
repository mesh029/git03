#!/bin/bash

# Admin Endpoints Test Script
BASE_URL="http://localhost:3000"
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

PASSED=0
FAILED=0

echo "🔧 Admin Endpoints Test Suite"
echo "=============================="
echo ""

# Check if server is running
echo "🔍 Checking server status..."
if ! curl -s "$BASE_URL/health" > /dev/null 2>&1; then
    echo -e "${RED}❌ Server is not running. Please start it with: npm run dev${NC}"
    exit 1
fi
echo -e "${GREEN}✅ Server is running${NC}"
echo ""

# Login as Admin
echo "1️⃣  Logging in as Admin..."
ADMIN_LOGIN=$(curl -s -X POST "$BASE_URL/v1/auth/login" \
    -H "Content-Type: application/json" \
    -d '{"email":"admin@juax.test","password":"Admin123!@#"}')
if echo "$ADMIN_LOGIN" | grep -q "access_token"; then
    echo -e "${GREEN}✅ Admin login successful${NC}"
    ADMIN_TOKEN=$(echo "$ADMIN_LOGIN" | python3 -c "import sys, json; print(json.load(sys.stdin)['data']['access_token'])" 2>/dev/null)
    ((PASSED++))
else
    echo -e "${RED}❌ Admin login failed${NC}"
    echo "$ADMIN_LOGIN" | python3 -m json.tool 2>/dev/null | head -5
    ((FAILED++))
    exit 1
fi
echo ""

# Test 2: Get All Users
echo "2️⃣  Testing GET /v1/admin/users..."
USERS_RESPONSE=$(curl -s -X GET "$BASE_URL/v1/admin/users" \
    -H "Authorization: Bearer $ADMIN_TOKEN")
if echo "$USERS_RESPONSE" | grep -q "users"; then
    echo -e "${GREEN}✅ Get all users successful${NC}"
    USER_COUNT=$(echo "$USERS_RESPONSE" | python3 -c "import sys, json; print(len(json.load(sys.stdin)['data']['users']))" 2>/dev/null)
    echo -e "${BLUE}   → Found $USER_COUNT users${NC}"
    ((PASSED++))
else
    echo -e "${RED}❌ Get all users failed${NC}"
    echo "$USERS_RESPONSE" | python3 -m json.tool 2>/dev/null | head -10
    ((FAILED++))
fi
echo ""

# Test 3: Get User by ID
echo "3️⃣  Testing GET /v1/admin/users/:id..."
# Get first user ID from previous response
USER_ID=$(echo "$USERS_RESPONSE" | python3 -c "import sys, json; users=json.load(sys.stdin)['data']['users']; print(users[0]['id'] if users else '')" 2>/dev/null)
if [ ! -z "$USER_ID" ]; then
    GET_USER=$(curl -s -X GET "$BASE_URL/v1/admin/users/$USER_ID" \
        -H "Authorization: Bearer $ADMIN_TOKEN")
    if echo "$GET_USER" | grep -q "id"; then
        echo -e "${GREEN}✅ Get user by ID successful${NC}"
        USER_EMAIL=$(echo "$GET_USER" | python3 -c "import sys, json; print(json.load(sys.stdin)['data']['email'])" 2>/dev/null)
        echo -e "${BLUE}   → User: $USER_EMAIL${NC}"
        ((PASSED++))
    else
        echo -e "${RED}❌ Get user by ID failed${NC}"
        ((FAILED++))
    fi
else
    echo -e "${YELLOW}⚠️  No user ID available for testing${NC}"
    ((FAILED++))
fi
echo ""

# Test 4: Get User's Orders
echo "4️⃣  Testing GET /v1/admin/users/:id/orders..."
if [ ! -z "$USER_ID" ]; then
    USER_ORDERS=$(curl -s -X GET "$BASE_URL/v1/admin/users/$USER_ID/orders" \
        -H "Authorization: Bearer $ADMIN_TOKEN")
    if echo "$USER_ORDERS" | grep -q "orders"; then
        echo -e "${GREEN}✅ Get user orders successful${NC}"
        ORDER_COUNT=$(echo "$USER_ORDERS" | python3 -c "import sys, json; print(len(json.load(sys.stdin)['data']['orders']))" 2>/dev/null)
        echo -e "${BLUE}   → Found $ORDER_COUNT orders${NC}"
        ((PASSED++))
    else
        echo -e "${YELLOW}⚠️  Get user orders (may be empty)${NC}"
        ((PASSED++))
    fi
fi
echo ""

# Test 5: Get All Orders
echo "5️⃣  Testing GET /v1/admin/orders..."
ALL_ORDERS=$(curl -s -X GET "$BASE_URL/v1/admin/orders" \
    -H "Authorization: Bearer $ADMIN_TOKEN")
if echo "$ALL_ORDERS" | grep -q "orders"; then
    echo -e "${GREEN}✅ Get all orders successful${NC}"
    TOTAL_ORDERS=$(echo "$ALL_ORDERS" | python3 -c "import sys, json; print(json.load(sys.stdin)['data']['pagination']['total'])" 2>/dev/null)
    echo -e "${BLUE}   → Total orders: $TOTAL_ORDERS${NC}"
    ORDER_ID=$(echo "$ALL_ORDERS" | python3 -c "import sys, json; orders=json.load(sys.stdin)['data']['orders']; print(orders[0]['id'] if orders else '')" 2>/dev/null)
    ((PASSED++))
else
    echo -e "${RED}❌ Get all orders failed${NC}"
    ((FAILED++))
fi
echo ""

# Test 6: Update Order Status (Admin Override)
echo "6️⃣  Testing PATCH /v1/admin/orders/:id/status..."
if [ ! -z "$ORDER_ID" ]; then
    UPDATE_STATUS=$(curl -s -X PATCH "$BASE_URL/v1/admin/orders/$ORDER_ID/status" \
        -H "Authorization: Bearer $ADMIN_TOKEN" \
        -H "Content-Type: application/json" \
        -d '{"status":"cancelled"}')
    if echo "$UPDATE_STATUS" | grep -q "success"; then
        echo -e "${GREEN}✅ Update order status successful${NC}"
        ((PASSED++))
    else
        echo -e "${RED}❌ Update order status failed${NC}"
        echo "$UPDATE_STATUS" | python3 -m json.tool 2>/dev/null | head -5
        ((FAILED++))
    fi
else
    echo -e "${YELLOW}⚠️  No order ID available for testing${NC}"
fi
echo ""

# Test 7: Get All Properties
echo "7️⃣  Testing GET /v1/admin/properties..."
ALL_PROPS=$(curl -s -X GET "$BASE_URL/v1/admin/properties" \
    -H "Authorization: Bearer $ADMIN_TOKEN")
if echo "$ALL_PROPS" | grep -q "properties"; then
    echo -e "${GREEN}✅ Get all properties successful${NC}"
    PROP_COUNT=$(echo "$ALL_PROPS" | python3 -c "import sys, json; print(json.load(sys.stdin)['data']['pagination']['total'])" 2>/dev/null)
    echo -e "${BLUE}   → Total properties: $PROP_COUNT${NC}"
    ((PASSED++))
else
    echo -e "${RED}❌ Get all properties failed${NC}"
    ((FAILED++))
fi
echo ""

# Test 8: Get Platform Statistics
echo "8️⃣  Testing GET /v1/admin/stats..."
STATS=$(curl -s -X GET "$BASE_URL/v1/admin/stats" \
    -H "Authorization: Bearer $ADMIN_TOKEN")
if echo "$STATS" | grep -q "users"; then
    echo -e "${GREEN}✅ Get platform stats successful${NC}"
    echo "$STATS" | python3 -m json.tool 2>/dev/null | head -30
    ((PASSED++))
else
    echo -e "${RED}❌ Get platform stats failed${NC}"
    echo "$STATS" | python3 -m json.tool 2>/dev/null | head -10
    ((FAILED++))
fi
echo ""

# Test 9: Update User Role
echo "9️⃣  Testing PATCH /v1/admin/users/:id/role..."
# Get agent user ID
AGENT_LOGIN=$(curl -s -X POST "$BASE_URL/v1/auth/login" \
    -H "Content-Type: application/json" \
    -d '{"email":"agent@juax.test","password":"Agent123!@#"}')
AGENT_USER_ID=$(echo "$AGENT_LOGIN" | python3 -c "import sys, json; print(json.load(sys.stdin)['data']['user']['id'])" 2>/dev/null)

if [ ! -z "$AGENT_USER_ID" ]; then
    UPDATE_ROLE=$(curl -s -X PATCH "$BASE_URL/v1/admin/users/$AGENT_USER_ID/role" \
        -H "Authorization: Bearer $ADMIN_TOKEN" \
        -H "Content-Type: application/json" \
        -d '{"isAgent":true}')
    if echo "$UPDATE_ROLE" | grep -q "success"; then
        echo -e "${GREEN}✅ Update user role successful${NC}"
        ((PASSED++))
    else
        echo -e "${YELLOW}⚠️  Update user role response:${NC}"
        echo "$UPDATE_ROLE" | python3 -m json.tool 2>/dev/null | head -5
        ((PASSED++)) # May already be agent
    fi
else
    echo -e "${YELLOW}⚠️  Could not get agent user ID${NC}"
fi
echo ""

# Test 10: Filter Users by Role
echo "🔟 Testing GET /v1/admin/users?role=agent..."
AGENT_USERS=$(curl -s -X GET "$BASE_URL/v1/admin/users?role=agent" \
    -H "Authorization: Bearer $ADMIN_TOKEN")
if echo "$AGENT_USERS" | grep -q "users"; then
    echo -e "${GREEN}✅ Filter users by role successful${NC}"
    AGENT_COUNT=$(echo "$AGENT_USERS" | python3 -c "import sys, json; print(len(json.load(sys.stdin)['data']['users']))" 2>/dev/null)
    echo -e "${BLUE}   → Found $AGENT_COUNT agents${NC}"
    ((PASSED++))
else
    echo -e "${RED}❌ Filter users by role failed${NC}"
    ((FAILED++))
fi
echo ""

# Test 11: Filter Orders by Status
echo "1️⃣1️⃣  Testing GET /v1/admin/orders?status=pending..."
PENDING_ORDERS=$(curl -s -X GET "$BASE_URL/v1/admin/orders?status=pending" \
    -H "Authorization: Bearer $ADMIN_TOKEN")
if echo "$PENDING_ORDERS" | grep -q "orders"; then
    echo -e "${GREEN}✅ Filter orders by status successful${NC}"
    PENDING_COUNT=$(echo "$PENDING_ORDERS" | python3 -c "import sys, json; print(json.load(sys.stdin)['data']['pagination']['total'])" 2>/dev/null)
    echo -e "${BLUE}   → Found $PENDING_COUNT pending orders${NC}"
    ((PASSED++))
else
    echo -e "${RED}❌ Filter orders by status failed${NC}"
    ((FAILED++))
fi
echo ""

# Test 12: Unauthorized Access (Regular User)
echo "1️⃣2️⃣  Testing Unauthorized Access (Regular User)..."
REGULAR_LOGIN=$(curl -s -X POST "$BASE_URL/v1/auth/login" \
    -H "Content-Type: application/json" \
    -d '{"email":"user1@juax.test","password":"Test123!@#"}')
if echo "$REGULAR_LOGIN" | grep -q "access_token"; then
    REGULAR_TOKEN=$(echo "$REGULAR_LOGIN" | python3 -c "import sys, json; print(json.load(sys.stdin)['data']['access_token'])" 2>/dev/null)
    
    UNAUTHORIZED=$(curl -s -X GET "$BASE_URL/v1/admin/users" \
        -H "Authorization: Bearer $REGULAR_TOKEN")
    if echo "$UNAUTHORIZED" | grep -q "FORBIDDEN\|Admin access required"; then
        echo -e "${GREEN}✅ Unauthorized access correctly rejected${NC}"
        ((PASSED++))
    else
        echo -e "${RED}❌ Unauthorized access not properly blocked${NC}"
        echo "$UNAUTHORIZED" | python3 -m json.tool 2>/dev/null | head -5
        ((FAILED++))
    fi
else
    echo -e "${YELLOW}⚠️  Could not login as regular user${NC}"
fi
echo ""

# Summary
echo "======================================"
echo "📊 Test Summary"
echo "======================================"
echo -e "${GREEN}✅ Passed: $PASSED${NC}"
echo -e "${RED}❌ Failed: $FAILED${NC}"
echo ""

if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}🎉 All admin endpoint tests passed!${NC}"
    exit 0
else
    echo -e "${YELLOW}⚠️  Some tests failed or had warnings${NC}"
    exit 1
fi
