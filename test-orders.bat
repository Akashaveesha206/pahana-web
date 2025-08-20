@echo off
echo 🧪 Testing Order Details API
echo =============================
echo.

echo 📋 Prerequisites:
echo 1. Backend should be running on http://localhost:8080
echo 2. Database should be set up with sample data
echo 3. You should have at least one order in the database
echo.

echo 🔍 Testing public endpoints...
echo.

echo 📚 Testing books endpoint...
curl -s http://localhost:8080/api/books | findstr "title"
if %ERRORLEVEL% EQU 0 (
    echo ✅ Books endpoint working
) else (
    echo ❌ Books endpoint failed
)

echo.
echo 🔐 Testing authentication...
echo.

echo 📝 Testing login endpoint...
curl -s -X POST http://localhost:8080/api/auth/signin -H "Content-Type: application/json" -d "{\"email\":\"admin@bookshop.com\",\"password\":\"admin123\"}" | findstr "accessToken"
if %ERRORLEVEL% EQU 0 (
    echo ✅ Login endpoint working
    echo.
    echo 💡 Copy the accessToken from the response above
    echo.
    echo 🔍 Now test the orders endpoint with the token:
    echo curl -H "Authorization: Bearer YOUR_TOKEN" http://localhost:8080/api/orders
) else (
    echo ❌ Login endpoint failed
)

echo.
echo 📊 Testing order endpoints...
echo.

echo 📋 Testing orders endpoint (without auth - should fail)...
curl -s http://localhost:8080/api/orders | findstr "Unauthorized"
if %ERRORLEVEL% EQU 0 (
    echo ✅ Orders endpoint properly protected
) else (
    echo ❌ Orders endpoint not properly protected
)

echo.
echo 🎯 Next Steps:
echo 1. Login with admin@bookshop.com / admin123
echo 2. Copy the accessToken from the response
echo 3. Test orders endpoint: curl -H "Authorization: Bearer YOUR_TOKEN" http://localhost:8080/api/orders
echo 4. Check if order items are included in the response
echo.

pause
