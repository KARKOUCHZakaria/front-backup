#!/bin/bash
# Backend Test Script for Linux/Mac
# This script tests all critical endpoints

BACKEND_URL="http://localhost:8081"

echo ""
echo "====================================="
echo "   Backend API Test Script"
echo "====================================="
echo ""

echo "[1/6] Testing Health Endpoint..."
curl -s $BACKEND_URL/actuator/health | jq .
echo ""
echo ""

echo "[2/6] Testing Registration..."
REGISTER_RESPONSE=$(curl -s -X POST $BACKEND_URL/auth/register \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","username":"Test User","password":"password123","phoneNumber":"+212600000000"}')
echo $REGISTER_RESPONSE | jq .
echo ""
echo ""

echo "[3/6] Testing Login..."
LOGIN_RESPONSE=$(curl -s -X POST $BACKEND_URL/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"password123"}')
echo $LOGIN_RESPONSE | jq .

# Extract token
TOKEN=$(echo $LOGIN_RESPONSE | jq -r '.data.token')
echo ""
echo "Token extracted: ${TOKEN:0:50}..."
echo ""
echo ""

echo "[4/6] Testing CORS Preflight..."
curl -s -X OPTIONS $BACKEND_URL/api/applications \
  -H "Origin: http://localhost:3000" \
  -H "Access-Control-Request-Method: POST" \
  -H "Access-Control-Request-Headers: Content-Type, Authorization" \
  -v 2>&1 | grep -i "access-control"
echo ""
echo ""

echo "[5/6] Testing Protected Endpoint (without token - should return 401)..."
curl -s -X GET $BACKEND_URL/api/applications/user/1 | jq .
echo ""
echo ""

if [ ! -z "$TOKEN" ] && [ "$TOKEN" != "null" ]; then
    echo "[6/6] Testing Protected Endpoint (with token - should succeed)..."
    curl -s -X GET $BACKEND_URL/api/applications/user/1 \
      -H "Authorization: Bearer $TOKEN" | jq .
    echo ""
else
    echo "[6/6] Skipping authenticated test (no token received)"
fi

echo ""
echo "====================================="
echo "   Test Complete!"
echo "====================================="
echo ""
echo "Next Steps:"
echo "1. Check all responses above"
echo "2. Verify no CORS errors"
echo "3. Verify 401 error for protected endpoint without token"
echo "4. Verify 200 success for protected endpoint with token"
echo "5. Test with Flutter app"
echo ""
