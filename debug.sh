#!/bin/bash

echo "=== Django Face Recognition Debugging Tool ==="
echo ""

# Check if container is running
echo "Checking container status..."
if ! docker-compose ps | grep -q "django_face_recog.*Up"; then
  echo "Error: Container is not running!"
  echo "Trying to start container..."
  docker-compose up -d
  sleep 5
fi

# Check Apache error logs
echo ""
echo "=== Apache Error Logs ==="
docker-compose exec web cat /var/log/apache2/error.log | tail -n 50

# Check Apache access logs
echo ""
echo "=== Apache Access Logs ==="
docker-compose exec web cat /var/log/apache2/access.log | tail -n 20

# Check wsgi.py file
echo ""
echo "=== WSGI File Content ==="
docker-compose exec web cat /app/django_face_recog/wsgi.py

# Check permissions
echo ""
echo "=== File Permissions ==="
docker-compose exec web ls -la /app/django_face_recog/
docker-compose exec web ls -la /app/django_face_recog/wsgi.py
docker-compose exec web ls -la /app/db.sqlite3

# Check Apache config
echo ""
echo "=== Apache Configuration ==="
docker-compose exec web apache2ctl -S

# Check Apache modules
echo ""
echo "=== Apache Modules ==="
docker-compose exec web apache2ctl -M | grep wsgi

# Fix common issues
echo ""
echo "Would you like to attempt fixing common issues? (y/n)"
read answer
if [[ "$answer" == "y" ]]; then
  echo "Applying fixes..."
  
  # Fix wsgi.py permissions
  docker-compose exec web chmod 755 /app/django_face_recog/wsgi.py
  docker-compose exec web chown www-data:www-data /app/django_face_recog/wsgi.py
  
  # Fix database permissions
  docker-compose exec web chown www-data:www-data /app/db.sqlite3
  docker-compose exec web chmod 664 /app/db.sqlite3
  
  # Restart Apache
  docker-compose exec web service apache2 restart
  
  echo "Fixes applied and Apache restarted. Please check if the issue is resolved."
fi

echo ""
echo "Debug information collected. Check the output above for issues."
echo "If you need more help, share this debug output with the support team." 