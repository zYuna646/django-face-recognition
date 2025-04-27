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
    gcc \
    openssl \
    ssl-cert \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements first for better caching
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
RUN pip install mod_wsgi

# Copy project files
COPY . .

# Install and configure mod_wsgi properly
RUN mod_wsgi-express install-module
# Create mod_wsgi load configuration
RUN echo "LoadModule wsgi_module $(find /usr/local/lib -name 'mod_wsgi*.so')" > /etc/apache2/mods-available/wsgi.load
# Enable the module
RUN a2enmod wsgi || echo "Module not found, continuing anyway"

# Copy Apache configuration
COPY apache-conf/000-default.conf /etc/apache2/sites-available/000-default.conf
COPY apache-conf/apache2.conf /etc/apache2/apache2.conf

# Make entrypoint script executable
RUN chmod +x /app/docker-entrypoint/entrypoint.sh

# Create required directories
RUN mkdir -p /app/staticfiles /app/media

# Expose both HTTP and HTTPS ports
EXPOSE 80 443

# Create a non-root user
RUN useradd -m appuser
RUN chown -R appuser:appuser /app

# Use our entrypoint script
ENTRYPOINT ["/app/docker-entrypoint/entrypoint.sh"] 