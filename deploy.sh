#!/bin/bash

# Build and start the Docker containers
docker-compose down
docker-compose build
docker-compose up -d

# Apply migrations
docker-compose exec web python manage.py migrate

# Create a superuser if needed (uncomment if necessary)
# docker-compose exec web python manage.py createsuperuser

echo "Django application deployed successfully at http://fer.webapps.digital" 