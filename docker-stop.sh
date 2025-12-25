#!/bin/bash
# Docker Stop Script for Linux/macOS

echo "Stopping all CreditAI services..."
echo ""

docker-compose stop

echo ""
echo "Services stopped successfully!"
echo ""
echo "To start again, run: ./docker-start.sh"
echo "To remove all data, run: docker-compose down -v"
echo ""
