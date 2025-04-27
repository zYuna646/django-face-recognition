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

# Install required Apache modules if they're missing
echo "Checking and installing Apache modules..."
apt-get update && apt-get install -y --no-install-recommends apache2-bin

# Make sure there are no stale Apache processes
echo "Stopping any running Apache process..."
pkill apache2 || true
rm -f /var/run/apache2/apache2.pid || true

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

# Check if MPM modules exist
echo "Checking Apache MPM modules..."
ls -la /usr/lib/apache2/modules/mod_mpm*

# Replace the apache2.conf with a simplified version to avoid MPM issues
echo "Creating simplified Apache configuration..."
cat > /etc/apache2/apache2.conf << 'EOL'
# Global configuration
ServerRoot "/etc/apache2"
ServerName localhost
Timeout 300
KeepAlive On
MaxKeepAliveRequests 100
KeepAliveTimeout 5

# Load MPM Prefork directly
LoadModule mpm_prefork_module /usr/lib/apache2/modules/mod_mpm_prefork.so

# Worker configuration
<IfModule mpm_prefork_module>
    StartServers          5
    MinSpareServers       5
    MaxSpareServers      10
    MaxRequestWorkers    150
    MaxConnectionsPerChild  0
</IfModule>

# Core modules
LoadModule authz_core_module /usr/lib/apache2/modules/mod_authz_core.so
LoadModule dir_module /usr/lib/apache2/modules/mod_dir.so
LoadModule mime_module /usr/lib/apache2/modules/mod_mime.so
LoadModule rewrite_module /usr/lib/apache2/modules/mod_rewrite.so
LoadModule alias_module /usr/lib/apache2/modules/mod_alias.so
LoadModule wsgi_module /usr/lib/apache2/modules/mod_wsgi.so

# Default MIME types
AddType application/x-compress .Z
AddType application/x-gzip .gz .tgz
AddType text/html .html .htm
AddType text/css .css
AddType text/javascript .js

# Logging configuration
ErrorLog /var/log/apache2/error.log
LogLevel warn
LogFormat "%h %l %u %t \"%r\" %>s %b" common
CustomLog /var/log/apache2/access.log common

# Listen directive
Listen 80

# Virtual hosts
IncludeOptional /etc/apache2/sites-enabled/*.conf
EOL

# Make sure log directory exists
mkdir -p /var/log/apache2

# Enable required Apache modules
echo "Enabling Apache modules..."
a2enmod rewrite

# Copy our virtual host configuration
echo "Setting up virtual host configuration..."
cp /app/apache-conf/000-default.conf /etc/apache2/sites-available/fer.webapps.digital.conf

# Disable default config and enable our site
a2dissite 000-default || true
a2ensite fer.webapps.digital

# Make sure /var/run/apache2 exists
mkdir -p /var/run/apache2

# Verify Apache configuration
echo "Verifying Apache configuration..."
apache2ctl configtest

# Start Apache in foreground
echo "Starting Apache..."
exec apache2ctl -D FOREGROUND 