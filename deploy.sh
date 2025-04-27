#!/bin/bash

# Check if port 8080 is already in use
port_check=$(netstat -tuln | grep ":8080")
if [ -n "$port_check" ]; then
  echo "Warning: Port 8080 is already in use. You may need to stop the running service or change the port in docker-compose.yml."
  echo "Proceeding with deployment anyway..."
fi

# Clean up Docker resources first
echo "Cleaning up Docker resources..."
docker-compose down
docker system prune -f --volumes
docker-compose rm -f

# Build and start the Docker containers
echo "Building and starting containers..."
docker-compose build --no-cache
docker-compose up -d

# Check if the container started successfully
if [ $? -ne 0 ]; then
  echo "Error: Docker container failed to start. Please check if ports are available."
  echo "You may need to modify the docker-compose.yml file to use a different port."
  echo "Current configuration uses host port 8080."
  exit 1
fi

# Apply migrations
echo "Applying database migrations..."
docker-compose exec web python manage.py migrate

# Create a superuser if needed (uncomment if necessary)
# docker-compose exec web python manage.py createsuperuser

# Copy Apache configuration to proper location with correct naming
echo "Setting up Apache configuration..."
docker-compose exec web cp /etc/apache2/sites-available/000-default.conf /etc/apache2/sites-available/fer.webapps.digital.conf
docker-compose exec web a2dissite 000-default.conf
docker-compose exec web a2ensite fer.webapps.digital.conf
docker-compose exec web service apache2 reload

# Ensure static files have proper permissions
echo "Setting proper permissions for static files..."
docker-compose exec web chmod -R 755 /app/static /app/staticfiles /app/media /app/upload
docker-compose exec web chown -R www-data:www-data /app/static /app/staticfiles /app/media /app/upload /app/db.sqlite3

# Fix permissions on the wsgi.py file
echo "Setting proper permissions for wsgi.py..."
docker-compose exec web chmod 755 /app/django_face_recog/wsgi.py
docker-compose exec web chown www-data:www-data /app/django_face_recog/wsgi.py

# Check Apache error logs
echo "Checking Apache error logs for issues..."
docker-compose exec web cat /var/log/apache2/error.log | tail -n 50

echo "Django application deployed successfully!"
echo "Access your site at http://fer.webapps.digital"
echo "If accessing directly via IP or localhost, use port 8080: http://localhost:8080"

# Provide debugging tips
echo ""
echo "If you're experiencing 'Internal Server Error', try these debugging steps:"
echo "1. Check Apache logs in detail: docker-compose exec web cat /var/log/apache2/error.log"
echo "2. Check Django app logs: docker-compose exec web cat /var/log/apache2/access.log"
echo "3. Restart Apache: docker-compose exec web service apache2 restart"
echo "4. Check file permissions: docker-compose exec web ls -la /app/django_face_recog/" 