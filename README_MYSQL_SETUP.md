# Bookshop MySQL Database Setup

This document provides instructions for setting up the MySQL database for the Bookshop application.

## Prerequisites

- MySQL 8.0 or higher installed and running
- MySQL client (mysql command line tool)
- Java 17 or higher
- Maven

## Database Configuration

The application is configured to connect to MySQL with the following settings:
- **Host**: localhost
- **Port**: 3306
- **Database**: bookshop
- **Username**: root
- **Password**: (empty/null)

## Setup Instructions

### 1. Start MySQL Server

Make sure MySQL server is running on your system.

### 2. Create Database and Tables

You can set up the database in two ways:

#### Option A: Using the provided SQL file

```bash
# Connect to MySQL as root
mysql -u root

# Run the database setup script
source /path/to/bookshop-backend/database.sql
```

#### Option B: Manual setup

```sql
-- Connect to MySQL and run these commands:

-- Create database
CREATE DATABASE IF NOT EXISTS bookshop CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE bookshop;

-- Run the contents of database.sql file
```

### 3. Verify Database Setup

After running the setup script, you should see:
- 2 users (admin and test user)
- 10 sample books
- 3 sample feedback entries

You can verify by running:
```sql
USE bookshop;
SELECT COUNT(*) as total_users FROM users;
SELECT COUNT(*) as total_books FROM books;
SELECT COUNT(*) as total_feedbacks FROM feedbacks;
```

## Default Users

The database comes with two default users:

### Admin User
- **Email**: admin@bookshop.com
- **Password**: admin123
- **Role**: ROLE_ADMIN, ROLE_USER

### Test User
- **Email**: user@bookshop.com
- **Password**: user123
- **Role**: ROLE_USER

## Database Schema

### Tables

1. **users** - User accounts and profiles
2. **user_roles** - User role assignments
3. **books** - Book catalog
4. **orders** - Customer orders
5. **order_items** - Individual items in orders
6. **feedbacks** - Customer feedback and reviews

### Key Features

- **Auto-incrementing IDs**: All primary keys use BIGINT AUTO_INCREMENT
- **Timestamps**: Automatic created_at and updated_at timestamps
- **Foreign Keys**: Proper referential integrity
- **Indexes**: Optimized for common queries
- **Soft Deletes**: Feedback uses is_visible flag for soft deletion

## Application Configuration

The application is configured in `application.properties`:

```properties
# MySQL Configuration
spring.datasource.url=jdbc:mysql://localhost:3306/bookshop?createDatabaseIfNotExist=true&useSSL=false&serverTimezone=UTC&allowPublicKeyRetrieval=true
spring.datasource.username=root
spring.datasource.password=
spring.datasource.driver-class-name=com.mysql.cj.jdbc.Driver

# JPA Configuration
spring.jpa.hibernate.ddl-auto=update
spring.jpa.show-sql=true
spring.jpa.properties.hibernate.dialect=org.hibernate.dialect.MySQL8Dialect
spring.jpa.properties.hibernate.format_sql=true
```

## Running the Application

1. **Build the project**:
   ```bash
   cd bookshop-backend
   mvn clean install
   ```

2. **Run the application**:
   ```bash
   mvn spring-boot:run
   ```

3. **Access the API**:
   - Backend: http://localhost:8080
   - API Documentation: http://localhost:8080/api/books

## Troubleshooting

### Common Issues

1. **Connection Refused**:
   - Ensure MySQL server is running
   - Check if MySQL is listening on port 3306

2. **Access Denied**:
   - Verify root user has no password (or update application.properties)
   - Check MySQL user permissions

3. **Database Not Found**:
   - Run the database.sql script to create the database
   - Check if the database name matches in application.properties

4. **Table Not Found**:
   - The application will create tables automatically with `spring.jpa.hibernate.ddl-auto=update`
   - Or run the database.sql script for manual setup

### Useful MySQL Commands

```sql
-- Check if database exists
SHOW DATABASES;

-- Use the database
USE bookshop;

-- Show all tables
SHOW TABLES;

-- Check table structure
DESCRIBE users;
DESCRIBE books;

-- Check data
SELECT * FROM users;
SELECT * FROM books LIMIT 5;
```

## Migration from MongoDB

This application has been converted from MongoDB to MySQL. Key changes:

1. **ID Types**: Changed from String to Long for all entity IDs
2. **Annotations**: Replaced MongoDB annotations with JPA annotations
3. **Queries**: Updated from MongoDB queries to JPQL
4. **Relationships**: Implemented proper foreign key relationships
5. **Timestamps**: Added automatic timestamp management

## Security Notes

- Default passwords are for development only
- Change passwords in production
- Consider encrypting sensitive data like payment information
- Use environment variables for database credentials in production

## Support

If you encounter issues:
1. Check the application logs for error messages
2. Verify MySQL server status and connectivity
3. Ensure all required tables are created
4. Check that the database user has proper permissions 