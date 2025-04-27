FROM python:3.9-slim

WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    libgl1-mesa-glx \
    libglib2.0-0 \
    libsm6 \
    libxrender1 \
    libxext6 \
    netcat-openbsd \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements first for better caching
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
RUN pip install gunicorn django-csp django-compressor

# Copy project files
COPY . .

# Create required directories and set permissions
RUN mkdir -p /app/staticfiles /app/static /app/media /app/static/CACHE/css
RUN chmod -R 755 /app/staticfiles /app/static /app/media
RUN touch /app/static/CACHE/css/output.53e39e3c3985.css
RUN chmod 644 /app/static/CACHE/css/output.53e39e3c3985.css

# Create simple entrypoint script
RUN echo '#!/bin/bash\n\
set -e\n\
\n\
# Make sure the SQLite database file exists and has proper permissions\n\
echo "Setting up SQLite database..."\n\
touch /app/db.sqlite3\n\
chmod 666 /app/db.sqlite3\n\
\n\
# Create necessary directories with proper permissions\n\
echo "Setting up directories..."\n\
mkdir -p /app/staticfiles /app/static /app/media /app/static/CACHE/css\n\
chmod -R 755 /app/staticfiles /app/static /app/media\n\
\n\
# Collect static files\n\
echo "Collecting static files..."\n\
python manage.py collectstatic --noinput --clear\n\
\n\
# Compress CSS\n\
echo "Compressing CSS..."\n\
python manage.py compress --force\n\
\n\
# Apply database migrations\n\
echo "Applying database migrations..."\n\
python manage.py migrate --noinput\n\
\n\
# Start Django with debug logging\n\
echo "Starting Django server..."\n\
exec gunicorn django_face_recog.wsgi:application --bind 0.0.0.0:3500 --log-level debug\n\
' > /app/entrypoint.sh && chmod +x /app/entrypoint.sh

# Expose the port Gunicorn runs on
EXPOSE 3500

# Use our new entrypoint script
ENTRYPOINT ["/app/entrypoint.sh"] 