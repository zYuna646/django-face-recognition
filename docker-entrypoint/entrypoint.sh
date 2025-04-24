#!/bin/bash
set -e

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

# Start Apache in foreground
echo "Starting Apache..."
exec apache2ctl -D FOREGROUND 