#!/bin/bash

# JuaX API Test Script
# This script tests all API endpoints with seeded data

BASE_URL="http://localhost:3000"
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "🧪 JuaX API Test Suite"
echo "======================"
echo ""

# Test 1: Health Check
echo "1️⃣  Testing Health Check..."
HEALTH=$(curl -s "$BASE_URL/health")
if echo "$HEALTH" | grep -q "healthy"; then
    echo -e "${GREEN}✅ Health check passed${NC}"
    echo "$HEALTH" | python3 -m json.tool 2>/dev/null || echo "$HEALTH"
else
    echo -e "${RED}❌ Health check failed${NC}"
    echo "$HEALTH"
    exit 1
fi
echo ""

# Test 2: User Registration
echo "2️⃣  Testing User Registration..."
REGISTER_RESPONSE=$(curl -s -X POST "$BASE_URL/v1/auth/register" \
    -H "Content-Type: application/json" \
    -d '{
        "email": "testuser@juax.test",
        "password": "Test123!@#",
        "name": "Test User",
        "phone": "+254712345999"
    }')
if echo "$REGISTER_RESPONSE" | grep -q "success"; then
    echo -e "${GREEN}✅ Registration successful${NC}"
    echo "$REGISTER_RESPONSE" | python3 -m json.tool 2>/dev/null || echo "$REGISTER_RESPONSE"
else
    echo -e "${YELLOW}⚠️  Registration response (may be duplicate user):${NC}"
    echo "$REGISTER_RESPONSE" | python3 -m json.tool 2>/dev/null || echo "$REGISTER_RESPONSE"
fi
echo ""

# Test 3: User Login
echo "3️⃣  Testing User Login..."
LOGIN_RESPONSE=$(curl -s -X POST "$BASE_URL/v1/auth/login" \
    -H "Content-Type: application/json" \
    -d '{
        "email": "user1@juax.test",
        "password": "Test123!@#"
    }')
if echo "$LOGIN_RESPONSE" | grep -q "access_token"; then
    echo -e "${GREEN}✅ Login successful${NC}"
    ACCESS_TOKEN=$(echo "$LOGIN_RESPONSE" | python3 -c "import sys, json; print(json.load(sys.stdin)['data']['access_token'])" 2>/dev/null)
    REFRESH_TOKEN=$(echo "$LOGIN_RESPONSE" | python3 -c "import sys, json; print(json.load(sys.stdin)['data']['refresh_token'])" 2>/dev/null)
    echo "Access Token: ${ACCESS_TOKEN:0:50}..."
    echo "Refresh Token: ${REFRESH_TOKEN:0:50}..."
else
    echo -e "${RED}❌ Login failed${NC}"
    echo "$LOGIN_RESPONSE" | python3 -m json.tool 2>/dev/null || echo "$LOGIN_RESPONSE"
    exit 1
fi
echo ""

# Test 4: Get Current User
echo "4️⃣  Testing Get Current User..."
ME_RESPONSE=$(curl -s -X GET "$BASE_URL/v1/auth/me" \
    -H "Authorization: Bearer $ACCESS_TOKEN")
if echo "$ME_RESPONSE" | grep -q "user1@juax.test"; then
    echo -e "${GREEN}✅ Get current user successful${NC}"
    echo "$ME_RESPONSE" | python3 -m json.tool 2>/dev/null || echo "$ME_RESPONSE"
else
    echo -e "${RED}❌ Get current user failed${NC}"
    echo "$ME_RESPONSE" | python3 -m json.tool 2>/dev/null || echo "$ME_RESPONSE"
fi
echo ""

# Test 5: Create Cleaning Order
echo "5️⃣  Testing Create Cleaning Order..."
CLEANING_ORDER=$(curl -s -X POST "$BASE_URL/v1/orders" \
    -H "Authorization: Bearer $ACCESS_TOKEN" \
    -H "Content-Type: application/json" \
    -d '{
        "type": "cleaning",
        "location": {
            "latitude": -1.2634,
            "longitude": 36.8007,
            "label": "Westlands, Nairobi"
        },
        "details": {
            "service": "deepCleaning",
            "rooms": 3
        }
    }')
if echo "$CLEANING_ORDER" | grep -q "id"; then
    echo -e "${GREEN}✅ Cleaning order created${NC}"
    ORDER_ID=$(echo "$CLEANING_ORDER" | python3 -c "import sys, json; print(json.load(sys.stdin)['data']['id'])" 2>/dev/null)
    echo "Order ID: $ORDER_ID"
    echo "$CLEANING_ORDER" | python3 -m json.tool 2>/dev/null || echo "$CLEANING_ORDER"
else
    echo -e "${RED}❌ Cleaning order creation failed${NC}"
    echo "$CLEANING_ORDER" | python3 -m json.tool 2>/dev/null || echo "$CLEANING_ORDER"
fi
echo ""

# Test 6: Create Laundry Order
echo "6️⃣  Testing Create Laundry Order..."
LAUNDRY_ORDER=$(curl -s -X POST "$BASE_URL/v1/orders" \
    -H "Authorization: Bearer $ACCESS_TOKEN" \
    -H "Content-Type: application/json" \
    -d '{
        "type": "laundry",
        "location": {
            "latitude": -0.0917,
            "longitude": 34.7680,
            "label": "Milimani Road, Kisumu"
        },
        "details": {
            "serviceType": "washAndFold",
            "quantity": 5,
            "items": ["shirts", "pants", "towels"]
        }
    }')
if echo "$LAUNDRY_ORDER" | grep -q "id"; then
    echo -e "${GREEN}✅ Laundry order created${NC}"
    echo "$LAUNDRY_ORDER" | python3 -m json.tool 2>/dev/null || echo "$LAUNDRY_ORDER"
else
    echo -e "${RED}❌ Laundry order creation failed${NC}"
    echo "$LAUNDRY_ORDER" | python3 -m json.tool 2>/dev/null || echo "$LAUNDRY_ORDER"
fi
echo ""

# Test 7: Create Property Booking Order
echo "7️⃣  Testing Create Property Booking Order..."
# Get property ID from seed output (first available property)
PROPERTY_ID="c35b4ff8-00f4-40f7-a052-23630b839fd7"
FUTURE_DATE=$(date -d "+7 days" -u +"%Y-%m-%dT14:00:00Z" 2>/dev/null || date -v+7d -u +"%Y-%m-%dT14:00:00Z" 2>/dev/null || echo "2024-02-15T14:00:00Z")
FUTURE_DATE_2=$(date -d "+10 days" -u +"%Y-%m-%dT11:00:00Z" 2>/dev/null || date -v+10d -u +"%Y-%m-%dT11:00:00Z" 2>/dev/null || echo "2024-02-18T11:00:00Z")

PROPERTY_BOOKING=$(curl -s -X POST "$BASE_URL/v1/orders" \
    -H "Authorization: Bearer $ACCESS_TOKEN" \
    -H "Content-Type: application/json" \
    -d "{
        \"type\": \"property_booking\",
        \"location\": {
            \"latitude\": -0.0917,
            \"longitude\": 34.7680,
            \"label\": \"Milimani Road, Kisumu\"
        },
        \"details\": {
            \"propertyId\": \"$PROPERTY_ID\",
            \"checkIn\": \"$FUTURE_DATE\",
            \"checkOut\": \"$FUTURE_DATE_2\",
            \"guests\": 2
        }
    }")
if echo "$PROPERTY_BOOKING" | grep -q "id"; then
    echo -e "${GREEN}✅ Property booking created${NC}"
    BOOKING_ORDER_ID=$(echo "$PROPERTY_BOOKING" | python3 -c "import sys, json; print(json.load(sys.stdin)['data']['id'])" 2>/dev/null)
    echo "Booking Order ID: $BOOKING_ORDER_ID"
    echo "$PROPERTY_BOOKING" | python3 -m json.tool 2>/dev/null || echo "$PROPERTY_BOOKING"
else
    echo -e "${RED}❌ Property booking creation failed${NC}"
    echo "$PROPERTY_BOOKING" | python3 -m json.tool 2>/dev/null || echo "$PROPERTY_BOOKING"
fi
echo ""

# Test 8: List Orders
echo "8️⃣  Testing List Orders..."
LIST_ORDERS=$(curl -s -X GET "$BASE_URL/v1/orders" \
    -H "Authorization: Bearer $ACCESS_TOKEN")
if echo "$LIST_ORDERS" | grep -q "orders"; then
    echo -e "${GREEN}✅ List orders successful${NC}"
    echo "$LIST_ORDERS" | python3 -m json.tool 2>/dev/null || echo "$LIST_ORDERS"
else
    echo -e "${RED}❌ List orders failed${NC}"
    echo "$LIST_ORDERS" | python3 -m json.tool 2>/dev/null || echo "$LIST_ORDERS"
fi
echo ""

# Test 9: Get Single Order
if [ ! -z "$ORDER_ID" ]; then
    echo "9️⃣  Testing Get Single Order..."
    GET_ORDER=$(curl -s -X GET "$BASE_URL/v1/orders/$ORDER_ID" \
        -H "Authorization: Bearer $ACCESS_TOKEN")
    if echo "$GET_ORDER" | grep -q "id"; then
        echo -e "${GREEN}✅ Get single order successful${NC}"
        echo "$GET_ORDER" | python3 -m json.tool 2>/dev/null || echo "$GET_ORDER"
    else
        echo -e "${RED}❌ Get single order failed${NC}"
        echo "$GET_ORDER" | python3 -m json.tool 2>/dev/null || echo "$GET_ORDER"
    fi
    echo ""
fi

# Test 10: Cancel Order
if [ ! -z "$ORDER_ID" ]; then
    echo "🔟 Testing Cancel Order..."
    CANCEL_ORDER=$(curl -s -X PATCH "$BASE_URL/v1/orders/$ORDER_ID/cancel" \
        -H "Authorization: Bearer $ACCESS_TOKEN")
    if echo "$CANCEL_ORDER" | grep -q "cancelled"; then
        echo -e "${GREEN}✅ Cancel order successful${NC}"
        echo "$CANCEL_ORDER" | python3 -m json.tool 2>/dev/null || echo "$CANCEL_ORDER"
    else
        echo -e "${RED}❌ Cancel order failed${NC}"
        echo "$CANCEL_ORDER" | python3 -m json.tool 2>/dev/null || echo "$CANCEL_ORDER"
    fi
    echo ""
fi

# Test 11: Test Property Booking Conflict
echo "1️⃣1️⃣  Testing Property Booking Conflict Detection..."
CONFLICT_BOOKING=$(curl -s -X POST "$BASE_URL/v1/orders" \
    -H "Authorization: Bearer $ACCESS_TOKEN" \
    -H "Content-Type: application/json" \
    -d "{
        \"type\": \"property_booking\",
        \"location\": {
            \"latitude\": -0.0917,
            \"longitude\": 34.7680,
            \"label\": \"Milimani Road, Kisumu\"
        },
        \"details\": {
            \"propertyId\": \"$PROPERTY_ID\",
            \"checkIn\": \"$FUTURE_DATE\",
            \"checkOut\": \"$FUTURE_DATE_2\",
            \"guests\": 2
        }
    }")
if echo "$CONFLICT_BOOKING" | grep -q "conflict\|not available"; then
    echo -e "${GREEN}✅ Conflict detection working correctly${NC}"
    echo "$CONFLICT_BOOKING" | python3 -m json.tool 2>/dev/null || echo "$CONFLICT_BOOKING"
else
    echo -e "${YELLOW}⚠️  Conflict detection response:${NC}"
    echo "$CONFLICT_BOOKING" | python3 -m json.tool 2>/dev/null || echo "$CONFLICT_BOOKING"
fi
echo ""

echo "✨ Test suite completed!"
echo ""
