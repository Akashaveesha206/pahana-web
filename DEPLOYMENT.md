# Production Deployment Guide

This guide provides step-by-step instructions for deploying the Bookshop application to production.

## Prerequisites

- **Server**: Ubuntu 20.04+ or CentOS 8+ (recommended)
- **Java**: OpenJDK 17 or higher
- **Database**: MySQL 8.0 or higher
- **Web Server**: Nginx (recommended)
- **SSL Certificate**: Let's Encrypt or commercial certificate
- **Domain**: Configured DNS pointing to your server

## Quick Deployment with Docker

### 1. Clone and Setup
```bash
git clone <your-repo>
cd pahana-web
```

### 2. Environment Configuration
Create `.env` file:
```bash
# Database
MYSQL_ROOT_PASSWORD=your_secure_password
MYSQL_DATABASE=bookshop
MYSQL_USER=bookshop
MYSQL_PASSWORD=your_secure_password

# Backend
SPRING_DATASOURCE_URL=jdbc:mysql://mysql:3306/bookshop
SPRING_DATASOURCE_USERNAME=bookshop
SPRING_DATASOURCE_PASSWORD=your_secure_password
BOOKSHOP_APP_JWT_SECRET=your_very_secure_jwt_secret
FRONTEND_URL=https://yourdomain.com

# Frontend
VITE_API_BASE_URL=https://yourdomain.com/api
```

### 3. Deploy with Docker Compose
```bash
# Development
docker-compose up -d

# Production (with Nginx)
docker-compose --profile production up -d
```

## Manual Deployment

### Backend Deployment

#### 1. Build Application
```bash
cd bookshop-backend
mvn clean package -DskipTests
```

#### 2. Create Service User
```bash
sudo useradd -r -s /bin/false bookshop
sudo mkdir -p /opt/bookshop-backend
sudo chown bookshop:bookshop /opt/bookshop-backend
```

#### 3. Deploy Files
```bash
sudo cp target/bookshop-backend-*.jar /opt/bookshop-backend/bookshop-backend.jar
sudo cp src/main/resources/application-prod.properties /opt/bookshop-backend/application.properties
```

#### 4. Create Systemd Service
```bash
sudo tee /etc/systemd/system/bookshop-backend.service > /dev/null <<EOF
[Unit]
Description=Bookshop Backend Application
After=network.target mysql.service

[Service]
Type=simple
User=bookshop
WorkingDirectory=/opt/bookshop-backend
ExecStart=/usr/bin/java -Xms512m -Xmx2g -jar bookshop-backend.jar
Restart=always
RestartSec=10
Environment="SPRING_PROFILES_ACTIVE=prod"
Environment="SPRING_DATASOURCE_URL=jdbc:mysql://localhost:3306/bookshop"
Environment="SPRING_DATASOURCE_USERNAME=bookshop"
Environment="SPRING_DATASOURCE_PASSWORD=your_password"
Environment="BOOKSHOP_APP_JWT_SECRET=your_jwt_secret"
Environment="FRONTEND_URL=https://yourdomain.com"

[Install]
WantedBy=multi-user.target
EOF
```

#### 5. Start Service
```bash
sudo systemctl daemon-reload
sudo systemctl enable bookshop-backend
sudo systemctl start bookshop-backend
sudo systemctl status bookshop-backend
```

### Frontend Deployment

#### 1. Build Application
```bash
cd bookshop-frontend
npm ci
npm run build
```

#### 2. Deploy to Nginx
```bash
sudo cp -r dist/* /var/www/bookshop/
sudo chown -R www-data:www-data /var/www/bookshop
```

#### 3. Nginx Configuration
```bash
sudo tee /etc/nginx/sites-available/bookshop > /dev/null <<EOF
server {
    listen 80;
    server_name yourdomain.com www.yourdomain.com;
    return 301 https://\$server_name\$request_uri;
}

server {
    listen 443 ssl http2;
    server_name yourdomain.com www.yourdomain.com;
    
    ssl_certificate /etc/letsencrypt/live/yourdomain.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/yourdomain.com/privkey.pem;
    
    root /var/www/bookshop;
    index index.html;
    
    # Gzip compression
    gzip on;
    gzip_vary on;
    gzip_min_length 1024;
    gzip_types text/plain text/css text/xml text/javascript application/javascript application/xml+rss application/json;
    
    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header X-Content-Type-Options "nosniff" always;
    
    # Cache static assets
    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }
    
    # Handle React Router
    location / {
        try_files \$uri \$uri/ /index.html;
    }
    
    # API proxy
    location /api/ {
        proxy_pass http://localhost:8080;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
EOF
```

#### 4. Enable Site
```bash
sudo ln -s /etc/nginx/sites-available/bookshop /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx
```

### SSL Certificate (Let's Encrypt)

#### 1. Install Certbot
```bash
sudo apt update
sudo apt install certbot python3-certbot-nginx
```

#### 2. Obtain Certificate
```bash
sudo certbot --nginx -d yourdomain.com -d www.yourdomain.com
```

#### 3. Auto-renewal
```bash
sudo crontab -e
# Add this line:
0 12 * * * /usr/bin/certbot renew --quiet
```

## Database Setup

### 1. Install MySQL
```bash
sudo apt update
sudo apt install mysql-server
sudo mysql_secure_installation
```

### 2. Create Database and User
```bash
sudo mysql -u root -p
```

```sql
CREATE DATABASE bookshop CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER 'bookshop'@'localhost' IDENTIFIED BY 'your_secure_password';
GRANT ALL PRIVILEGES ON bookshop.* TO 'bookshop'@'localhost';
FLUSH PRIVILEGES;
EXIT;
```

### 3. Import Schema
```bash
mysql -u bookshop -p bookshop < bookshop-backend/database.sql
```

## Monitoring and Logs

### 1. Application Logs
```bash
# Backend logs
sudo journalctl -u bookshop-backend -f

# Nginx logs
sudo tail -f /var/log/nginx/access.log
sudo tail -f /var/log/nginx/error.log
```

### 2. System Monitoring
```bash
# Install monitoring tools
sudo apt install htop iotop nethogs

# Check service status
sudo systemctl status bookshop-backend nginx mysql
```

### 3. Performance Monitoring
```bash
# Check memory usage
free -h

# Check disk usage
df -h

# Check CPU usage
top
```

## Security Hardening

### 1. Firewall Configuration
```bash
sudo ufw allow 22/tcp    # SSH
sudo ufw allow 80/tcp    # HTTP
sudo ufw allow 443/tcp   # HTTPS
sudo ufw enable
```

### 2. Database Security
```bash
# Remove anonymous users
sudo mysql -u root -p
DELETE FROM mysql.user WHERE User='';
FLUSH PRIVILEGES;
EXIT;
```

### 3. Application Security
- Change default passwords
- Use strong JWT secrets
- Enable HTTPS only
- Regular security updates

## Backup Strategy

### 1. Database Backup
```bash
# Create backup script
sudo tee /opt/backup-db.sh > /dev/null <<EOF
#!/bin/bash
BACKUP_DIR="/opt/backups"
DATE=\$(date +%Y%m%d_%H%M%S)
mysqldump -u bookshop -p bookshop > \$BACKUP_DIR/bookshop_\$DATE.sql
gzip \$BACKUP_DIR/bookshop_\$DATE.sql
find \$BACKUP_DIR -name "*.sql.gz" -mtime +7 -delete
EOF

sudo chmod +x /opt/backup-db.sh

# Add to crontab
sudo crontab -e
# Add this line:
0 2 * * * /opt/backup-db.sh
```

### 2. Application Backup
```bash
# Backup application files
sudo tar -czf /opt/backups/app_$(date +%Y%m%d_%H%M%S).tar.gz /opt/bookshop-backend /var/www/bookshop
```

## Troubleshooting

### Common Issues

1. **Service won't start**
   - Check logs: `sudo journalctl -u bookshop-backend -f`
   - Verify configuration files
   - Check file permissions

2. **Database connection failed**
   - Verify MySQL is running: `sudo systemctl status mysql`
   - Check credentials in application.properties
   - Verify database exists

3. **Frontend not loading**
   - Check Nginx status: `sudo systemctl status nginx`
   - Verify file permissions in /var/www/bookshop
   - Check Nginx configuration: `sudo nginx -t`

4. **SSL certificate issues**
   - Verify certificate validity: `sudo certbot certificates`
   - Check Nginx SSL configuration
   - Ensure domain DNS is properly configured

## Performance Optimization

### 1. JVM Tuning
```bash
# Optimize JVM options in systemd service
ExecStart=/usr/bin/java -Xms1g -Xmx2g -XX:+UseG1GC -XX:+UseStringDeduplication -jar bookshop-backend.jar
```

### 2. Database Optimization
```sql
-- Add indexes for better performance
CREATE INDEX idx_orders_user_id ON orders(user_id);
CREATE INDEX idx_orders_status ON orders(status);
CREATE INDEX idx_books_category ON books(category);
```

### 3. Nginx Optimization
```nginx
# Enable gzip compression
gzip on;
gzip_comp_level 6;
gzip_types text/plain text/css application/json application/javascript;

# Enable caching
location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg)$ {
    expires 1y;
    add_header Cache-Control "public, immutable";
}
```

## Support

For deployment issues:
1. Check the logs first
2. Verify all prerequisites are met
3. Ensure proper file permissions
4. Check network connectivity
5. Create an issue in the repository

---

**Note**: Always test your deployment in a staging environment before going to production.
