FROM python:3.10-slim

# Install required system packages
RUN apt-get update && apt-get install -y \
    build-essential \
    libgl1-mesa-glx \
    libglib2.0-0 \
    apache2 \
    apache2-dev \
    libapache2-mod-wsgi-py3 \
    vim \
    procps \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Copy requirements file
COPY requirements.txt .

# Create and activate virtual environment
RUN python -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# Install dependencies in virtual environment
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt && \
    pip install mod_wsgi

# Copy project files
COPY . .

# Collect static files
RUN python manage.py collectstatic --noinput

# Create a wsgi.py fix script
RUN echo '#!/bin/bash\n\
if [ -f /app/django_face_recog/wsgi.py ]; then\n\
    echo "Fixing wsgi.py file..."\n\
    sed -i "s/^application = get_wsgi_application()/import sys\\napplication = get_wsgi_application()/g" /app/django_face_recog/wsgi.py\n\
    echo "WSGI file content:"\n\
    cat /app/django_face_recog/wsgi.py\n\
fi' > /fix_wsgi.sh && chmod +x /fix_wsgi.sh

# Setup Apache configuration
COPY apache/django.conf /etc/apache2/sites-available/000-default.conf
COPY apache/django.conf /etc/apache2/sites-available/fer.webapps.digital.conf

# Remove default Apache welcome page
RUN rm -f /var/www/html/index.html

# Create necessary directories
RUN mkdir -p /app/media /app/staticfiles

# Set permissions for media and static directories
RUN chmod -R 755 /app/static /app/staticfiles /app/media /app/upload && \
    chown -R www-data:www-data /app/static /app/staticfiles /app/media /app/upload

# Make sure wsgi.py has proper permissions
RUN chmod 755 /app/django_face_recog/wsgi.py && \
    chown www-data:www-data /app/django_face_recog/wsgi.py

# Make sure WSGIPythonPath is properly set
RUN echo "WSGIPythonPath /app:/opt/venv/lib/python3.10/site-packages" > /etc/apache2/conf-available/wsgi.conf && \
    a2enconf wsgi

# Enable necessary Apache modules and sites
RUN a2enmod wsgi headers rewrite && \
    a2dissite 000-default.conf && \
    a2ensite fer.webapps.digital.conf

# Set up startup script with additional checks
RUN echo '#!/bin/bash\n\
echo "Running startup script..."\n\
/fix_wsgi.sh\n\
\n\
# Remove default Apache welcome page\n\
rm -f /var/www/html/index.html\n\
\n\
# Fix permissions for SQLite database\n\
mkdir -p $(dirname /app/db.sqlite3)\n\
touch /app/db.sqlite3\n\
chown www-data:www-data /app/db.sqlite3\n\
chmod 664 /app/db.sqlite3\n\
\n\
# Check Apache configuration\n\
echo "Testing Apache configuration..."\n\
apache2ctl configtest\n\
\n\
# Restart Apache cleanly\n\
echo "Starting Apache..."\n\
apache2ctl stop || true\n\
sleep 2\n\
apache2ctl -D FOREGROUND' > /start.sh && chmod +x /start.sh

# Expose port
EXPOSE 80

# Run startup script
CMD ["/start.sh"] 