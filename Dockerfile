FROM python:3.9-slim

WORKDIR /app

# Install system dependencies including Apache and mod_wsgi
RUN apt-get update && apt-get install -y --no-install-recommends \
    libgl1-mesa-glx \
    libglib2.0-0 \
    libsm6 \
    libxrender1 \
    libxext6 \
    apache2 \
    apache2-dev \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements first for better caching
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
RUN pip install mod_wsgi

# Copy project files
COPY . .

# Configure Apache
RUN mod_wsgi-express install-module
COPY apache-conf/000-default.conf /etc/apache2/sites-available/000-default.conf
COPY apache-conf/apache2.conf /etc/apache2/apache2.conf
RUN a2enmod wsgi

# Collect static files
RUN python manage.py collectstatic --noinput

# Expose the port Apache runs on
EXPOSE 80

# Create a non-root user
RUN useradd -m appuser
RUN chown -R appuser:appuser /app

# Run Apache in the foreground
CMD ["apache2ctl", "-D", "FOREGROUND"] 