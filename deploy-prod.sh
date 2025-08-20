#!/bin/bash

# Production Deployment Script for Bookshop Backend
echo "🚀 Starting production deployment..."

# Set environment
export SPRING_PROFILES_ACTIVE=prod

# Clean and build
echo "🧹 Cleaning previous build..."
mvn clean

echo "🔨 Building JAR file..."
mvn package -DskipTests

# Check build success
if [ $? -eq 0 ]; then
    echo "✅ Build successful!"
    
    # Create deployment directory
    DEPLOY_DIR="deploy-$(date +%Y%m%d-%H%M%S)"
    mkdir -p $DEPLOY_DIR
    
    # Copy JAR and configuration
    echo "📦 Preparing deployment package..."
    cp target/bookshop-backend-*.jar $DEPLOY_DIR/bookshop-backend.jar
    cp src/main/resources/application-prod.properties $DEPLOY_DIR/application.properties
    
    # Create startup script
    cat > $DEPLOY_DIR/start.sh << 'EOF'
#!/bin/bash
export SPRING_PROFILES_ACTIVE=prod
export JAVA_OPTS="-Xms512m -Xmx2g -XX:+UseG1GC -XX:+UseStringDeduplication"
java $JAVA_OPTS -jar bookshop-backend.jar
EOF
    
    chmod +x $DEPLOY_DIR/start.sh
    
    # Create systemd service file
    cat > $DEPLOY_DIR/bookshop-backend.service << 'EOF'
[Unit]
Description=Bookshop Backend Application
After=network.target

[Service]
Type=simple
User=bookshop
WorkingDirectory=/opt/bookshop-backend
ExecStart=/opt/bookshop-backend/start.sh
Restart=always
RestartSec=10
Environment="SPRING_PROFILES_ACTIVE=prod"

[Install]
WantedBy=multi-user.target
EOF
    
    # Create deployment instructions
    cat > $DEPLOY_DIR/DEPLOYMENT_INSTRUCTIONS.md << 'EOF'
# Production Deployment Instructions

## 1. Upload Files
Upload all files in this directory to your server at `/opt/bookshop-backend/`

## 2. Set Environment Variables
```bash
export SPRING_DATASOURCE_URL=jdbc:mysql://your-db-host:3306/bookshop
export SPRING_DATASOURCE_USERNAME=your-db-username
export SPRING_DATASOURCE_PASSWORD=your-db-password
export BOOKSHOP_APP_JWT_SECRET=your-secure-jwt-secret
export FRONTEND_URL=https://yourdomain.com
```

## 3. Install as Service
```bash
sudo cp bookshop-backend.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable bookshop-backend
sudo systemctl start bookshop-backend
```

## 4. Check Status
```bash
sudo systemctl status bookshop-backend
sudo journalctl -u bookshop-backend -f
```

## 5. Firewall Configuration
```bash
sudo ufw allow 8080/tcp
```
EOF
    
    # Create deployment package
    echo "📦 Creating deployment package..."
    tar -czf bookshop-backend-prod-$(date +%Y%m%d-%H%M%S).tar.gz $DEPLOY_DIR/
    
    echo "🎉 Production deployment package created successfully!"
    echo "📁 Deployment directory: $DEPLOY_DIR/"
    echo "📦 Deployment package: bookshop-backend-prod-*.tar.gz"
    echo "📖 See DEPLOYMENT_INSTRUCTIONS.md for deployment steps"
    
    # Cleanup
    rm -rf $DEPLOY_DIR
else
    echo "❌ Build failed!"
    exit 1
fi
