#!/bin/bash

# Create necessary directories
mkdir -p media

# Check if .env file exists
if [ ! -f .env ]; then
    echo "Creating .env file from example..."
    cp env.example .env
    echo "Please update the .env file with your settings before continuing."
    exit 1
fi

# Ensure docker compose is installed
if command -v docker &> /dev/null; then
    if ! docker compose version &> /dev/null; then
        echo "Docker Compose functionality not found. Please ensure you have Docker Compose installed."
        exit 1
    fi
else
    echo "Docker not found. Please install Docker and Docker Compose."
    exit 1
fi

# Build and start containers
echo "Building and starting containers..."
docker compose down --remove-orphans
docker compose -f docker-compose.prod.yml up -d --build

echo "Setup complete! Your Django application should be accessible via Nginx at https://fer.zyuna646.tech"
echo "Please ensure Nginx is configured correctly and that it's reloaded:"
echo "sudo nginx -t && sudo systemctl reload nginx" 