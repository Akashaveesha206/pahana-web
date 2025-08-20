@echo off
REM Production Deployment Script for Bookshop Backend (Windows)
echo 🚀 Starting production deployment...

REM Set environment
set SPRING_PROFILES_ACTIVE=prod

REM Clean and build
echo 🧹 Cleaning previous build...
call mvn clean

echo 🔨 Building JAR file...
call mvn package -DskipTests

REM Check build success
if %ERRORLEVEL% EQU 0 (
    echo ✅ Build successful!
    
    REM Create deployment directory
    set TIMESTAMP=%date:~-4,4%%date:~-10,2%%date:~-7,2%-%time:~0,2%%time:~3,2%%time:~6,2%
    set TIMESTAMP=%TIMESTAMP: =0%
    set DEPLOY_DIR=deploy-%TIMESTAMP%
    mkdir %DEPLOY_DIR%
    
    REM Copy JAR and configuration
    echo 📦 Preparing deployment package...
    copy target\bookshop-backend-*.jar %DEPLOY_DIR%\bookshop-backend.jar
    copy src\main\resources\application-prod.properties %DEPLOY_DIR%\application.properties
    
    REM Create startup script
    echo @echo off > %DEPLOY_DIR%\start.bat
    echo set SPRING_PROFILES_ACTIVE=prod >> %DEPLOY_DIR%\start.bat
    echo set JAVA_OPTS=-Xms512m -Xmx2g -XX:+UseG1GC -XX:+UseStringDeduplication >> %DEPLOY_DIR%\start.bat
    echo java %%JAVA_OPTS%% -jar bookshop-backend.jar >> %DEPLOY_DIR%\start.bat
    
    REM Create deployment instructions
    echo # Production Deployment Instructions > %DEPLOY_DIR%\DEPLOYMENT_INSTRUCTIONS.md
    echo. >> %DEPLOY_DIR%\DEPLOYMENT_INSTRUCTIONS.md
    echo ## 1. Upload Files >> %DEPLOY_DIR%\DEPLOYMENT_INSTRUCTIONS.md
    echo Upload all files in this directory to your server at `/opt/bookshop-backend/` >> %DEPLOY_DIR%\DEPLOYMENT_INSTRUCTIONS.md
    echo. >> %DEPLOY_DIR%\DEPLOYMENT_INSTRUCTIONS.md
    echo ## 2. Set Environment Variables >> %DEPLOY_DIR%\DEPLOYMENT_INSTRUCTIONS.md
    echo ```bash >> %DEPLOY_DIR%\DEPLOYMENT_INSTRUCTIONS.md
    echo export SPRING_DATASOURCE_URL=jdbc:mysql://your-db-host:3306/bookshop >> %DEPLOY_DIR%\DEPLOYMENT_INSTRUCTIONS.md
    echo export SPRING_DATASOURCE_USERNAME=your-db-username >> %DEPLOY_DIR%\DEPLOYMENT_INSTRUCTIONS.md
    echo export SPRING_DATASOURCE_PASSWORD=your-db-password >> %DEPLOY_DIR%\DEPLOYMENT_INSTRUCTIONS.md
    echo export BOOKSHOP_APP_JWT_SECRET=your-secure-jwt-secret >> %DEPLOY_DIR%\DEPLOYMENT_INSTRUCTIONS.md
    echo export FRONTEND_URL=https://yourdomain.com >> %DEPLOY_DIR%\DEPLOYMENT_INSTRUCTIONS.md
    echo ``` >> %DEPLOY_DIR%\DEPLOYMENT_INSTRUCTIONS.md
    
    REM Create deployment package
    echo 📦 Creating deployment package...
    powershell Compress-Archive -Path %DEPLOY_DIR% -DestinationPath "bookshop-backend-prod-%TIMESTAMP%.zip"
    
    echo 🎉 Production deployment package created successfully!
    echo 📁 Deployment directory: %DEPLOY_DIR%/
    echo 📦 Deployment package: bookshop-backend-prod-%TIMESTAMP%.zip
    echo 📖 See DEPLOYMENT_INSTRUCTIONS.md for deployment steps
    
    REM Cleanup
    rmdir /s /q %DEPLOY_DIR%
) else (
    echo ❌ Build failed!
    exit /b 1
)
