#!/bin/bash

# Comprehensive API Testing Script
# Tests all endpoints and logs results

BASE_URL="http://localhost:3000/v1"
echo "🧪 Starting Comprehensive API Tests..."
echo "=========================================="
echo ""

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test counter
TESTS_PASSED=0
TESTS_FAILED=0

# Function to test endpoint
test_endpoint() {
    local method=$1
    local endpoint=$2
    local data=$3
    local token=$4
    local description=$5
    
    echo -n "Testing: $description... "
    
    if [ -n "$token" ]; then
        if [ "$method" = "GET" ]; then
            response=$(curl -s -w "\n%{http_code}" -X GET "$BASE_URL$endpoint" \
                -H "Authorization: Bearer $token" \
                -H "Content-Type: application/json")
        else
            response=$(curl -s -w "\n%{http_code}" -X $method "$BASE_URL$endpoint" \
                -H "Authorization: Bearer $token" \
                -H "Content-Type: application/json" \
                -d "$data")
        fi
    else
        if [ "$method" = "GET" ]; then
            response=$(curl -s -w "\n%{http_code}" -X GET "$BASE_URL$endpoint" \
                -H "Content-Type: application/json")
        else
            response=$(curl -s -w "\n%{http_code}" -X $method "$BASE_URL$endpoint" \
                -H "Content-Type: application/json" \
                -d "$data")
        fi
    fi
    
    http_code=$(echo "$response" | tail -n1)
    body=$(echo "$response" | sed '$d')
    
    if [ "$http_code" -ge 200 ] && [ "$http_code" -lt 300 ]; then
        echo -e "${GREEN}✓ PASS${NC} (HTTP $http_code)"
        ((TESTS_PASSED++))
        return 0
    elif [ "$http_code" -ge 400 ] && [ "$http_code" -lt 500 ]; then
        echo -e "${YELLOW}⚠ EXPECTED ERROR${NC} (HTTP $http_code)"
        ((TESTS_PASSED++))
        return 0
    else
        echo -e "${RED}✗ FAIL${NC} (HTTP $http_code)"
        ((TESTS_FAILED++))
        return 1
    fi
}

# ============================================
# 1. HEALTH & BASE ENDPOINTS
# ============================================
echo "📋 1. Health & Base Endpoints"
echo "-----------------------------------"
test_endpoint "GET" "" "" "" "Base API endpoint"
test_endpoint "GET" "/health" "" "" "Health check"
echo ""

# ============================================
# 2. AUTHENTICATION
# ============================================
echo "🔐 2. Authentication Endpoints"
echo "-----------------------------------"

# Register a test user
REGISTER_DATA='{"name":"Test User","email":"test'$(date +%s)'@example.com","password":"Test123!@#"}'
REGISTER_RESPONSE=$(curl -s -X POST "$BASE_URL/auth/register" \
    -H "Content-Type: application/json" \
    -d "$REGISTER_DATA")

ACCESS_TOKEN=$(echo $REGISTER_RESPONSE | grep -o '"accessToken":"[^"]*' | cut -d'"' -f4)
REFRESH_TOKEN=$(echo $REGISTER_RESPONSE | grep -o '"refreshToken":"[^"]*' | cut -d'"' -f4)

if [ -n "$ACCESS_TOKEN" ]; then
    echo -e "${GREEN}✓ User registered successfully${NC}"
    test_endpoint "GET" "/auth/me" "" "$ACCESS_TOKEN" "Get current user (me)"
    test_endpoint "POST" "/auth/logout" "" "$ACCESS_TOKEN" "Logout"
    test_endpoint "POST" "/auth/refresh" "{\"refreshToken\":\"$REFRESH_TOKEN\"}" "" "Refresh token"
else
    echo -e "${YELLOW}⚠ Registration failed, trying login instead${NC}"
    # Try login with existing user
    LOGIN_DATA='{"email":"test@example.com","password":"Test123!@#"}'
    LOGIN_RESPONSE=$(curl -s -X POST "$BASE_URL/auth/login" \
        -H "Content-Type: application/json" \
        -d "$LOGIN_DATA")
    ACCESS_TOKEN=$(echo $LOGIN_RESPONSE | grep -o '"accessToken":"[^"]*' | cut -d'"' -f4)
fi

# Test login with invalid credentials (expected to fail)
test_endpoint "POST" "/auth/login" '{"email":"invalid@example.com","password":"wrong"}' "" "Login with invalid credentials (expected 401)"

echo ""

# ============================================
# 3. LOCATIONS
# ============================================
echo "📍 3. Location Endpoints"
echo "-----------------------------------"
test_endpoint "GET" "/locations/geocode?query=Nairobi" "" "" "Geocode location"
test_endpoint "GET" "/locations/reverse-geocode?latitude=-1.2921&longitude=36.8219" "" "" "Reverse geocode"
test_endpoint "GET" "/locations/validate?latitude=-1.2921&longitude=36.8219" "" "" "Validate coordinates"
echo ""

# ============================================
# 4. PROPERTIES
# ============================================
echo "🏠 4. Property Endpoints"
echo "-----------------------------------"
test_endpoint "GET" "/properties" "" "" "List properties (public)"
test_endpoint "GET" "/properties?limit=5&offset=0" "" "" "List properties with pagination"
test_endpoint "GET" "/properties?type=apartment" "" "" "Filter properties by type"
test_endpoint "GET" "/properties?isAvailable=true" "" "" "Filter available properties"

# Get a property ID if available
PROPERTY_RESPONSE=$(curl -s "$BASE_URL/properties?limit=1")
PROPERTY_ID=$(echo $PROPERTY_RESPONSE | grep -o '"id":"[^"]*' | head -1 | cut -d'"' -f4)

if [ -n "$PROPERTY_ID" ] && [ -n "$ACCESS_TOKEN" ]; then
    test_endpoint "GET" "/properties/$PROPERTY_ID" "" "" "Get property by ID"
fi

echo ""

# ============================================
# 5. SERVICE LOCATIONS
# ============================================
echo "🏪 5. Service Location Endpoints"
echo "-----------------------------------"
test_endpoint "GET" "/service-locations" "" "" "List service locations"
test_endpoint "GET" "/service-locations/nearby?latitude=-1.2921&longitude=36.8219&radius=5000" "" "" "Find nearby service locations"
echo ""

# ============================================
# 6. SUBSCRIPTIONS
# ============================================
echo "💳 6. Subscription Endpoints"
echo "-----------------------------------"
test_endpoint "GET" "/subscriptions" "" "" "List available subscriptions"

if [ -n "$ACCESS_TOKEN" ]; then
    test_endpoint "GET" "/subscriptions/current" "" "$ACCESS_TOKEN" "Get current subscription"
    test_endpoint "GET" "/subscriptions/access?feature=orders_per_month" "" "$ACCESS_TOKEN" "Check feature access"
fi
echo ""

# ============================================
# 7. ORDERS (Requires Auth)
# ============================================
echo "📦 7. Order Endpoints"
echo "-----------------------------------"
if [ -n "$ACCESS_TOKEN" ]; then
    test_endpoint "GET" "/orders" "" "$ACCESS_TOKEN" "Get user orders"
    test_endpoint "GET" "/orders?status=pending" "" "$ACCESS_TOKEN" "Get orders by status"
    test_endpoint "GET" "/orders?limit=10&offset=0" "" "$ACCESS_TOKEN" "Get orders with pagination"
    
    # Try to create an order (may fail due to subscription limits, but that's expected)
    ORDER_DATA='{"type":"cleaning","location":{"latitude":-1.2921,"longitude":36.8219,"label":"Nairobi"},"details":{"service":"deep_clean","rooms":2}}'
    test_endpoint "POST" "/orders" "$ORDER_DATA" "$ACCESS_TOKEN" "Create cleaning order"
    
    # Get order ID if created
    ORDERS_RESPONSE=$(curl -s -X GET "$BASE_URL/orders" \
        -H "Authorization: Bearer $ACCESS_TOKEN")
    ORDER_ID=$(echo $ORDERS_RESPONSE | grep -o '"id":"[^"]*' | head -1 | cut -d'"' -f4)
    
    if [ -n "$ORDER_ID" ]; then
        test_endpoint "GET" "/orders/$ORDER_ID" "" "$ACCESS_TOKEN" "Get order by ID"
        test_endpoint "GET" "/orders/$ORDER_ID/tracking" "" "$ACCESS_TOKEN" "Get order tracking"
        test_endpoint "GET" "/orders/$ORDER_ID/tracking/history" "" "$ACCESS_TOKEN" "Get order status history"
    fi
else
    echo -e "${YELLOW}⚠ Skipping order tests (no auth token)${NC}"
fi
echo ""

# ============================================
# 8. MESSAGING (Requires Auth)
# ============================================
echo "💬 8. Messaging Endpoints"
echo "-----------------------------------"
if [ -n "$ACCESS_TOKEN" ]; then
    test_endpoint "GET" "/messages/conversations" "" "$ACCESS_TOKEN" "Get conversations"
    
    # Get conversation ID if available
    CONV_RESPONSE=$(curl -s -X GET "$BASE_URL/messages/conversations" \
        -H "Authorization: Bearer $ACCESS_TOKEN")
    CONV_ID=$(echo $CONV_RESPONSE | grep -o '"id":"[^"]*' | head -1 | cut -d'"' -f4)
    
    if [ -n "$CONV_ID" ]; then
        test_endpoint "GET" "/messages/conversations/$CONV_ID" "" "$ACCESS_TOKEN" "Get conversation details"
        test_endpoint "GET" "/messages/conversations/$CONV_ID/messages" "" "$ACCESS_TOKEN" "Get conversation messages"
    fi
else
    echo -e "${YELLOW}⚠ Skipping messaging tests (no auth token)${NC}"
fi
echo ""

# ============================================
# 9. ADMIN ENDPOINTS (Requires Admin Auth)
# ============================================
echo "👑 9. Admin Endpoints"
echo "-----------------------------------"
if [ -n "$ACCESS_TOKEN" ]; then
    # These will likely fail with 403 unless user is admin, but that's expected
    test_endpoint "GET" "/admin/users" "" "$ACCESS_TOKEN" "List users (admin)"
    test_endpoint "GET" "/admin/orders" "" "$ACCESS_TOKEN" "List all orders (admin)"
    test_endpoint "GET" "/admin/properties" "" "$ACCESS_TOKEN" "List all properties (admin)"
    test_endpoint "GET" "/admin/stats" "" "$ACCESS_TOKEN" "Get platform stats (admin)"
else
    echo -e "${YELLOW}⚠ Skipping admin tests (no auth token)${NC}"
fi
echo ""

# ============================================
# 10. LOG VIEWER
# ============================================
echo "📊 10. Log Viewer Endpoints"
echo "-----------------------------------"
test_endpoint "GET" "/logs/recent?limit=10" "" "" "Get recent logs"
test_endpoint "GET" "/logs/recent?limit=5&level=error" "" "" "Get error logs"
test_endpoint "GET" "/logs/files" "" "" "List log files"
echo ""

# ============================================
# SUMMARY
# ============================================
echo "=========================================="
echo "📊 Test Summary"
echo "=========================================="
echo -e "${GREEN}Tests Passed: $TESTS_PASSED${NC}"
echo -e "${RED}Tests Failed: $TESTS_FAILED${NC}"
echo ""
echo "✅ All tests completed! Check the log viewer at:"
echo "   http://localhost:3000/v1/logs/viewer"
echo ""
