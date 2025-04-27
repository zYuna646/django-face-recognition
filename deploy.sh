#!/bin/bash

echo "Starting deployment with Gunicorn and Apache..."

# Stop running containers
docker-compose down

# Build and start new containers
docker-compose up -d --build

echo "Deployment complete! The app is now running at http://fer.webapps.digital:8080/"
echo "Architecture: Apache (port 8080) -> Gunicorn (port 3500) -> Django"
echo "The application is using a Python virtual environment at /opt/venv inside the container"

# Check logs
echo "Checking logs (Ctrl+C to exit):"
docker-compose logs -f 