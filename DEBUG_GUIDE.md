# 🔍 Authentication Debug Guide

This guide will help you troubleshoot the authentication issues you're experiencing with the admin endpoints.

## 🚨 **Current Issue**
You're getting "Unauthorized" errors when trying to access:
- `http://localhost:8080/api/feedback/public`
- Admin feedback and orders pages

## 🔧 **Step-by-Step Debug Process**

### 1. **Check if Backend is Running**
```bash
# Navigate to backend directory
cd bookshop-backend

# Start the backend
mvn spring-boot:run
```

**Expected Output:**
- Spring Boot should start without errors
- You should see "Started BookshopBackendApplication" in the console
- Backend should be accessible at `http://localhost:8080`

### 2. **Check if Database is Running**
```bash
# Check if MySQL is running (Windows)
# Open XAMPP Control Panel and start MySQL

# Or check via command line
mysql -u root -p
# Enter your MySQL password (default: empty)
```

**Expected Output:**
- MySQL should start without errors
- You should be able to connect to the database

### 3. **Verify Database Setup**
```bash
# Connect to MySQL and check if database exists
mysql -u root -p
USE bookshop;
SHOW TABLES;
SELECT * FROM users;
SELECT * FROM user_roles;
```

**Expected Output:**
- You should see tables: `users`, `user_roles`, `books`, `orders`, `feedbacks`
- You should see at least one admin user: `admin@bookshop.com`

### 4. **Test Authentication Endpoints**

#### **Test Login (Should Work)**
```bash
curl -X POST http://localhost:8080/api/auth/signin \
  -H "Content-Type: application/json" \
  -d '{
    "email": "admin@bookshop.com",
    "password": "admin123"
  }'
```

**Expected Output:**
```json
{
  "id": 1,
  "email": "admin@bookshop.com",
  "name": "Admin",
  "roles": ["ROLE_ADMIN"],
  "accessToken": "eyJhbGciOiJIUzI1NiJ9..."
}
```

#### **Test Admin Endpoint (Should Work with Token)**
```bash
# Copy the accessToken from the login response
curl -X GET http://localhost:8080/api/admin/debug \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN_HERE"
```

**Expected Output:**
```json
{
  "authenticated": true,
  "email": "admin@bookshop.com",
  "name": "Admin",
  "authorities": ["ROLE_ADMIN"],
  "id": "1"
}
```

### 5. **Frontend Debug Steps**

#### **Open Browser Console**
1. Open your browser
2. Navigate to `http://localhost:5173`
3. Open Developer Tools (F12)
4. Go to Console tab

#### **Check Authentication State**
```javascript
// In browser console, run:
localStorage.getItem("token")
localStorage.getItem("user")
localStorage.getItem("isAuthenticated")
```

**Expected Output:**
- `token`: Should contain a JWT token
- `user`: Should contain user data with `isAdmin: true`
- `isAuthenticated`: Should be "true"

#### **Debug Authentication**
```javascript
// In browser console, run:
AuthService.debugAuthState()
```

**Expected Output:**
```
=== Authentication Debug Info ===
Token exists: true
Token length: [some number]
User exists: true
IsAuthenticated flag: true
User data: {id: 1, name: "Admin", email: "admin@bookshop.com", isAdmin: true, roles: ["ROLE_ADMIN"]}
User roles: ["ROLE_ADMIN"]
Is admin: true
Login time: [timestamp]
Token payload: {sub: "admin@bookshop.com", roles: ["ROLE_ADMIN"], exp: [timestamp], iat: [timestamp]}
Token expiration: [date]
Token issued at: [date]
Current time: [date]
Token expired: false
Session valid: true
================================
```

### 6. **Common Issues and Solutions**

#### **Issue: "Token exists: false"**
**Solution:** You need to log in first
1. Go to `/login` page
2. Login with `admin@bookshop.com` / `admin123`
3. Check localStorage again

#### **Issue: "Token expired: true"**
**Solution:** Token has expired, need to login again
1. Logout and login again
2. Or clear localStorage and login again

#### **Issue: "Is admin: false"**
**Solution:** User doesn't have admin role
1. Check database: `SELECT * FROM user_roles WHERE user_id = 1;`
2. Should show `ROLE_ADMIN`
3. If not, run the database setup script again

#### **Issue: Backend not starting**
**Solution:** Check for errors
1. Look at the console output
2. Common issues: MySQL not running, port 8080 in use
3. Fix the underlying issue and restart

#### **Issue: Database connection failed**
**Solution:** Check MySQL configuration
1. Verify MySQL is running
2. Check `application.properties` for correct database settings
3. Ensure database `bookshop` exists

### 7. **Quick Test Commands**

#### **Test Backend Health**
```bash
curl http://localhost:8080/api/health
```

#### **Test Public Endpoints**
```bash
curl http://localhost:8080/api/books
curl http://localhost:8080/api/feedback/public
```

#### **Test Protected Endpoints (with token)**
```bash
# Replace YOUR_TOKEN with actual token
curl -H "Authorization: Bearer YOUR_TOKEN" http://localhost:8080/api/admin/debug
curl -H "Authorization: Bearer YOUR_TOKEN" http://localhost:8080/api/admin/feedbacks
```

### 8. **Reset Everything (Nuclear Option)**

If nothing works, reset everything:

```bash
# 1. Stop all services
# 2. Clear database
mysql -u root -p
DROP DATABASE bookshop;
CREATE DATABASE bookshop;

# 3. Restart MySQL
# 4. Run database setup
cd bookshop-backend
mysql -u root -p bookshop < database.sql

# 5. Restart backend
mvn spring-boot:run

# 6. Clear frontend localStorage
# In browser console:
localStorage.clear()

# 7. Login again
# Go to /login and login with admin@bookshop.com / admin123
```

## 📞 **Need Help?**

If you're still having issues after following this guide:

1. **Check the console logs** - Look for error messages
2. **Verify all prerequisites** - Java 17, MySQL 8.0, Node.js 18
3. **Check network tab** - See what requests are failing
4. **Share error messages** - Copy the exact error text

## 🎯 **Expected End Result**

After following this guide, you should be able to:
- ✅ Access admin pages without "Unauthorized" errors
- ✅ View feedbacks and orders in admin panel
- ✅ See proper authentication state in browser console
- ✅ Make successful API calls to protected endpoints

---

**Remember:** The key is to ensure the backend is running, the database is properly set up, and you're logged in as an admin user with a valid JWT token.
