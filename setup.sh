#!/bin/bash

# Make script exit on first error
set -e

echo "Setting up Django Face Recognition Docker environment..."

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "Docker is not installed. Please install Docker first."
    exit 1
fi

# Check if Docker Compose is installed
if ! command -v docker-compose &> /dev/null; then
    echo "Docker Compose is not installed. Please install Docker Compose first."
    exit 1
fi

# Create necessary directories if they don't exist
mkdir -p media
mkdir -p static
mkdir -p upload

# Set correct permissions
chmod -R 755 media
chmod -R 755 static
chmod -R 755 upload

# Build and start Docker containers
echo "Building and starting Docker containers..."
docker-compose up -d --build

# Show container status
docker-compose ps

echo "Setup complete! Your Django application should be running at http://fer.webapps.digital/"
echo "If you're running this locally, add 'fer.webapps.digital' to your hosts file pointing to 127.0.0.1" 