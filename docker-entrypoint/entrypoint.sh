#!/bin/bash
set -e

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

# Ensure mod_wsgi is properly configured
WSGI_MODULE_PATH=$(ls /usr/lib/apache2/modules/mod_wsgi-py*.so 2>/dev/null || echo "")
if [ -n "$WSGI_MODULE_PATH" ]; then
    echo "Found mod_wsgi module at: $WSGI_MODULE_PATH"
    # Create a loadmodule.conf file for Apache
    echo "LoadModule wsgi_module $WSGI_MODULE_PATH" > /etc/apache2/mods-available/wsgi.load
    echo "WSGIPythonHome /usr" >> /etc/apache2/mods-available/wsgi.load
    a2enmod wsgi || echo "Failed to enable wsgi module, continuing anyway"
else
    echo "WARNING: mod_wsgi module not found!"
fi

# Start Apache in foreground
echo "Starting Apache..."
exec apache2ctl -D FOREGROUND 