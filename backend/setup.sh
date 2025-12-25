#!/bin/bash

# Setup script for Ethical AI Credit Scoring Backend

echo "==================================="
echo "Backend Setup Script"
echo "==================================="

# Check Java version
echo "Checking Java version..."
if ! command -v java &> /dev/null; then
    echo "❌ Java is not installed. Please install Java 17 or higher."
    exit 1
fi

JAVA_VERSION=$(java -version 2>&1 | awk -F '"' '/version/ {print $2}' | cut -d'.' -f1)
if [ "$JAVA_VERSION" -lt 17 ]; then
    echo "❌ Java version must be 17 or higher. Current version: $JAVA_VERSION"
    exit 1
fi
echo "✅ Java version: $JAVA_VERSION"

# Check Maven
echo "Checking Maven..."
if ! command -v mvn &> /dev/null; then
    echo "❌ Maven is not installed. Please install Maven 3.8+."
    exit 1
fi
echo "✅ Maven is installed"

# Check PostgreSQL
echo "Checking PostgreSQL..."
if ! command -v psql &> /dev/null; then
    echo "⚠️ PostgreSQL CLI not found. Make sure PostgreSQL server is running."
else
    echo "✅ PostgreSQL CLI found"
fi

# Create database
echo ""
echo "Creating database..."
read -p "Do you want to create the database now? (y/n): " create_db

if [ "$create_db" == "y" ]; then
    read -p "Enter PostgreSQL username (default: postgres): " pg_user
    pg_user=${pg_user:-postgres}
    
    psql -U $pg_user -c "CREATE DATABASE credit_scoring_db;" 2>/dev/null
    if [ $? -eq 0 ]; then
        echo "✅ Database created successfully"
    else
        echo "⚠️ Database might already exist or creation failed"
    fi
fi

# Set up environment variables
echo ""
echo "Setting up environment variables..."
cat > .env << EOF
# Database Configuration
DB_USERNAME=postgres
DB_PASSWORD=postgres

# JWT Secret (256+ bits)
JWT_SECRET=YourSuperSecretKeyForJWTTokenGenerationMustBeAtLeast256BitsLong

# ML Service URL
ML_SERVICE_URL=http://localhost:8000

# File Upload Directory
FILE_UPLOAD_DIR=./uploads
EOF

echo "✅ Environment file created (.env)"

# Create uploads directory
echo ""
echo "Creating uploads directory..."
mkdir -p uploads
echo "✅ Uploads directory created"

# Build project
echo ""
echo "Building project..."
mvn clean install -DskipTests

if [ $? -eq 0 ]; then
    echo "✅ Build successful"
else
    echo "❌ Build failed"
    exit 1
fi

# Summary
echo ""
echo "==================================="
echo "Setup Complete!"
echo "==================================="
echo ""
echo "Next steps:"
echo "1. Update .env file with your database credentials"
echo "2. Ensure PostgreSQL is running on localhost:5432"
echo "3. Ensure ML service is running on localhost:8000"
echo "4. Run: mvn spring-boot:run"
echo ""
echo "The backend will be available at:"
echo "  - http://localhost:8081"
echo "  - http://10.0.2.2:8081 (Android emulator)"
echo ""
