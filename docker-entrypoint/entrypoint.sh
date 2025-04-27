#!/bin/bash
set -e

# Make sure the SQLite database file exists and has proper permissions
echo "Setting up SQLite database..."
touch /app/db.sqlite3
chmod 666 /app/db.sqlite3

# Collect static files
echo "Collecting static files..."
python manage.py collectstatic --noinput || echo "Collectstatic failed, continuing anyway"

# Apply database migrations
echo "Applying database migrations..."
python manage.py migrate --noinput

# Create a superuser if DJANGO_SUPERUSER_* environment variables are set
if [ -n "$DJANGO_SUPERUSER_USERNAME" ] && [ -n "$DJANGO_SUPERUSER_EMAIL" ] && [ -n "$DJANGO_SUPERUSER_PASSWORD" ]; then
    echo "Creating superuser..."
    python manage.py createsuperuser \
        --noinput \
        --username $DJANGO_SUPERUSER_USERNAME \
        --email $DJANGO_SUPERUSER_EMAIL || true
    python -c "
import os
import django
django.setup()
from django.contrib.auth import get_user_model
User = get_user_model()
if User.objects.filter(username='$DJANGO_SUPERUSER_USERNAME').exists():
    user = User.objects.get(username='$DJANGO_SUPERUSER_USERNAME')
    user.set_password('$DJANGO_SUPERUSER_PASSWORD')
    user.save()
"
fi

# Properly configure mod_wsgi for Apache
echo "Configuring mod_wsgi for Apache..."
# Find the actual mod_wsgi path
WSGI_MODULE_PATH=$(find /usr/local -name 'mod_wsgi*.so' 2>/dev/null)
if [ -n "$WSGI_MODULE_PATH" ]; then
    echo "Found mod_wsgi module at: $WSGI_MODULE_PATH"
    
    # Remove old mod_wsgi.so symlink if it exists
    rm -f /usr/lib/apache2/modules/mod_wsgi.so
    
    # Create directory if it doesn't exist
    mkdir -p /usr/lib/apache2/modules/
    
    # Create a proper symlink to the module
    ln -sf $WSGI_MODULE_PATH /usr/lib/apache2/modules/mod_wsgi.so
    
    # Update Apache configuration
    echo "LoadModule wsgi_module /usr/lib/apache2/modules/mod_wsgi.so" > /etc/apache2/mods-available/wsgi.load
    echo "WSGIPythonHome /usr" >> /etc/apache2/mods-available/wsgi.load
    
    # Enable the module
    a2enmod wsgi
else
    echo "ERROR: mod_wsgi module not found! Apache will not start properly."
    exit 1
fi

# Enable SSL module
echo "Enabling SSL module for Apache..."
a2enmod ssl
a2enmod socache_shmcb

# Create self-signed certificate if not exists
if [ ! -f /etc/ssl/certs/ssl-cert-snakeoil.pem ]; then
    echo "Creating self-signed SSL certificate..."
    mkdir -p /etc/ssl/private /etc/ssl/certs
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
        -keyout /etc/ssl/private/ssl-cert-snakeoil.key \
        -out /etc/ssl/certs/ssl-cert-snakeoil.pem \
        -subj "/CN=fer.webapps.digital"
fi

# Verify Apache configuration
echo "Verifying Apache configuration..."
apache2ctl configtest

# Start Apache in foreground
echo "Starting Apache..."
exec apache2ctl -D FOREGROUND 