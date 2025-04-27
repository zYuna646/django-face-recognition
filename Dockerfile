FROM python:3.9-slim

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
ENV DEBUG=False
ENV ALLOWED_HOSTS=localhost,127.0.0.1,fer.webapps.digital
ENV VIRTUAL_ENV=/opt/venv
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    apache2 \
    apache2-dev \
    build-essential \
    libpq-dev \
    libgl1-mesa-glx \
    libglib2.0-0 \
    libsm6 \
    libxrender1 \
    libxext6 \
    ffmpeg \
    python3-venv \
    supervisor \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Setup virtual environment
RUN python -m venv $VIRTUAL_ENV

# Set up the working directory
WORKDIR /app

# Install Python dependencies
COPY requirements.txt .
RUN $VIRTUAL_ENV/bin/pip install --no-cache-dir -r requirements.txt
RUN $VIRTUAL_ENV/bin/pip install gunicorn

# Copy the project code
COPY . .

# Collect static files
RUN $VIRTUAL_ENV/bin/python manage.py collectstatic --noinput

# Set up Apache configuration
RUN echo "Listen 8080" > /etc/apache2/ports.conf
RUN echo "ServerName fer.webapps.digital" >> /etc/apache2/apache2.conf
COPY apache/fer.webapps.digital.conf /etc/apache2/sites-available/
RUN a2ensite fer.webapps.digital
RUN a2dissite 000-default
RUN a2dissite django || true

# Add hosts entry for the domain
RUN echo "127.0.0.1 fer.webapps.digital" >> /etc/hosts

# Create directory for Apache run
RUN mkdir -p /var/run/apache2

# Enable required Apache modules
RUN a2enmod rewrite proxy proxy_http headers

# Set up supervisor configuration to manage both Apache and Gunicorn
COPY supervisor/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Expose port 8080
EXPOSE 8080

# Start supervisor to manage both processes
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"] 