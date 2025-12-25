#!/bin/bash
# Docker Quick Start Script for Linux/macOS

set -e

echo "========================================"
echo " CreditAI Docker Deployment"
echo "========================================"
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo -e "${RED}[ERROR]${NC} Docker is not installed"
    echo "Please install Docker from: https://docs.docker.com/get-docker/"
    exit 1
fi

echo -e "${GREEN}[OK]${NC} Docker is installed"
echo ""

# Check if Docker is running
if ! docker ps &> /dev/null; then
    echo -e "${RED}[ERROR]${NC} Docker is not running"
    echo "Please start Docker daemon and try again"
    exit 1
fi

echo -e "${GREEN}[OK]${NC} Docker is running"
echo ""

# Check if docker-compose is available
if ! command -v docker-compose &> /dev/null; then
    echo -e "${RED}[ERROR]${NC} docker-compose is not installed"
    exit 1
fi

echo -e "${GREEN}[OK]${NC} docker-compose is installed"
echo ""

echo "Starting all services..."
echo "This may take 5-10 minutes on first run (downloading images and building)"
echo ""

# Build and start services
docker-compose up -d --build

if [ $? -eq 0 ]; then
    echo ""
    echo "========================================"
    echo " Services Started Successfully!"
    echo "========================================"
    echo ""
    echo "Waiting for services to be healthy..."
    sleep 30
    
    # Check service status
    docker-compose ps
    
    echo ""
    echo "========================================"
    echo " Access Your Application:"
    echo "========================================"
    echo ""
    echo "Frontend:          http://localhost:3000"
    echo "Backend API:       http://localhost:8081"
    echo "Backend Swagger:   http://localhost:8081/swagger-ui.html"
    echo "ML Service:        http://localhost:8000"
    echo "ML API Docs:       http://localhost:8000/docs"
    echo "PostgreSQL:        localhost:5432"
    echo ""
    echo "========================================"
    echo " Useful Commands:"
    echo "========================================"
    echo ""
    echo "View logs:         docker-compose logs -f"
    echo "Stop services:     docker-compose stop"
    echo "Restart services:  docker-compose restart"
    echo "Remove all:        docker-compose down -v"
    echo ""
    echo -e "${GREEN}Setup complete!${NC} Opening frontend..."
    
    # Try to open browser (macOS/Linux)
    if command -v open &> /dev/null; then
        open http://localhost:3000
    elif command -v xdg-open &> /dev/null; then
        xdg-open http://localhost:3000
    fi
    
    echo ""
    echo "To view logs, run: docker-compose logs -f"
else
    echo ""
    echo -e "${RED}[ERROR]${NC} Failed to start services"
    echo "Run 'docker-compose logs' to see errors"
    exit 1
fi
