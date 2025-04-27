#!/bin/bash

echo "Cleaning up Docker environment..."

# Stop running containers
echo "Stopping all running containers..."
docker-compose down

# Remove old containers
echo "Removing old containers..."
docker rm -f $(docker ps -a -q --filter "name=django-face-app") 2>/dev/null || true

# Remove old images
echo "Removing old images..."
docker rmi -f $(docker images | grep 'django-face-app' | awk '{print $3}') 2>/dev/null || true

# Prune Docker system
echo "Pruning Docker system..."
docker system prune -f

echo "Cleanup complete! Now you can rebuild with './setup.sh'" 