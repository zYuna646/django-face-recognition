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
    apache2-utils \
    gcc \
    openssl \
    ssl-cert \
    mime-support \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements first for better caching
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
RUN pip install mod_wsgi

# Copy project files
COPY . .

# Install mod_wsgi
RUN mod_wsgi-express install-module

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