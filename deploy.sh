#!/bin/bash

# Clean up Docker resources first
echo "Cleaning up Docker resources..."
docker-compose down
docker system prune -f --volumes
docker-compose rm -f

# Build and start the Docker containers
echo "Building and starting containers..."
docker-compose build --no-cache
docker-compose up -d

# Apply migrations
echo "Applying database migrations..."
docker-compose exec web python manage.py migrate

# Create a superuser if needed (uncomment if necessary)
# docker-compose exec web python manage.py createsuperuser

# Copy Apache configuration to proper location
echo "Setting up Apache configuration..."
docker-compose exec web cp /etc/apache2/sites-available/000-default.conf /etc/apache2/sites-available/fer.conf
docker-compose exec web a2ensite fer.conf
docker-compose exec web service apache2 reload

# Ensure static files have proper permissions
echo "Setting proper permissions for static files..."
docker-compose exec web chmod -R 755 /app/static /app/staticfiles /app/media /app/upload
docker-compose exec web chown -R www-data:www-data /app/static /app/staticfiles /app/media /app/upload /app/db.sqlite3

echo "Django application deployed successfully at http://fer.webapps.digital" 