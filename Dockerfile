FROM python:3.10-slim

# Install required system packages
RUN apt-get update && apt-get install -y \
    build-essential \
    libgl1-mesa-glx \
    libglib2.0-0 \
    apache2 \
    apache2-dev \
    libapache2-mod-wsgi-py3 \
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

# Setup Apache configuration
COPY apache/django.conf /etc/apache2/sites-available/000-default.conf
COPY apache/django.conf /etc/apache2/sites-available/fer.webapps.digital.conf

# Create necessary directories
RUN mkdir -p /app/media /app/staticfiles

# Set permissions for media and static directories
RUN chmod -R 755 /app/static /app/staticfiles /app/media /app/upload && \
    chown -R www-data:www-data /app/static /app/staticfiles /app/media /app/upload /app/db.sqlite3

# Enable necessary Apache modules and sites
RUN a2enmod wsgi headers rewrite && \
    a2dissite 000-default.conf && \
    a2ensite fer.webapps.digital.conf

# Expose port
EXPOSE 80

# Run Apache in foreground
CMD ["apache2ctl", "-D", "FOREGROUND"] 