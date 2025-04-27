#!/bin/bash

echo "=== RESTARTING DOCKER CONTAINERS ==="

# Stop current containers
echo "Stopping containers..."
docker-compose down

# Update configuration
echo "Rebuilding containers..."
docker-compose build --no-cache

# Start containers
echo "Starting containers..."
docker-compose up -d

# Wait for container to be ready
echo "Waiting for container to be ready..."
sleep 5

# Check if container is running
if ! docker-compose ps | grep -q "django_face_recog.*Up"; then
  echo "ERROR: Container failed to start!"
  echo "Checking logs..."
  docker-compose logs
  exit 1
fi

# Check Apache error logs
echo "Checking Apache error logs..."
docker-compose exec web cat /var/log/apache2/error.log | tail -n 20

echo "Django application should be running at http://fer.webapps.digital"
echo "If you're using localhost, access with: http://localhost:8080" 