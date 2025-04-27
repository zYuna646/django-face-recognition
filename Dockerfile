FROM python:3.11-slim

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1
ENV VIRTUAL_ENV=/opt/venv

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    libopencv-dev \
    python3-opencv \
    apache2 \
    libapache2-mod-wsgi-py3 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Create and activate virtual environment
RUN python -m venv $VIRTUAL_ENV
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

# Set working directory
WORKDIR /app

# Copy requirements file
COPY requirements.txt .

# Install Python dependencies in the virtual environment
RUN pip install --upgrade pip && \
    pip install -r requirements.txt

# Copy project files
COPY . .

# Collect static files
RUN python manage.py collectstatic --noinput

# Create media directory with correct permissions
RUN mkdir -p /app/media && chmod 755 /app/media
RUN mkdir -p /app/upload && chmod 755 /app/upload

# Expose port for Apache
EXPOSE 80

# Copy the Apache configuration file
COPY apache-config.conf /etc/apache2/sites-available/000-default.conf

# Enable required Apache modules
RUN a2enmod wsgi
RUN a2enmod headers

# Set permissions for Apache
RUN chown -R www-data:www-data /app

# Use Apache as the entrypoint
CMD ["apache2ctl", "-D", "FOREGROUND"] 