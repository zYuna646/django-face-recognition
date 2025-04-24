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

# Install mod_wsgi but don't configure Apache
RUN mod_wsgi-express install-module
# Create a symlink for the module to be recognized by a2enmod
RUN ln -s /usr/lib/apache2/modules/mod_wsgi-py*.so /usr/lib/apache2/modules/mod_wsgi.so
# Now enable the module
RUN a2enmod wsgi || echo "Module not found, continuing anyway"

# Make entrypoint script executable
RUN chmod +x /app/docker-entrypoint/entrypoint.sh

# Expose the port Apache runs on
EXPOSE 80

# Create a non-root user
RUN useradd -m appuser
RUN chown -R appuser:appuser /app

# Use our entrypoint script
ENTRYPOINT ["/app/docker-entrypoint/entrypoint.sh"] 