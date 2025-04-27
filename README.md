# Django Face Recognition Application

This application is dockerized for easy deployment using Apache with WSGI.

## Deployment Instructions

1. Make sure Docker and Docker Compose are installed on your server.

2. Update your domain DNS settings to point to your server IP address.

3. Customize the environment variables in `docker-compose.yml`:
   ```yaml
   environment:
     - DEBUG=False
     - SECRET_KEY=your_production_secret_key_here  # Change this!
     - ALLOWED_HOSTS=fer.webapps.digital,localhost,127.0.0.1
     - SQLITE_DB_PATH=/app/db.sqlite3
   ```

4. Make the deployment script executable:
   ```bash
   chmod +x deploy.sh
   ```

5. Run the deployment script:
   ```bash
   ./deploy.sh
   ```

## File Structure

- `Dockerfile`: Defines the container build process
- `docker-compose.yml`: Defines the services and environment
- `apache/django.conf`: Apache virtual host configuration
- `deploy.sh`: Deployment helper script

## Important Notes

- Static files are served from `/app/staticfiles/`
- Media files are served from `/app/media/`
- Upload files are served from `/app/upload/`
- Database is SQLite3 located at `/app/db.sqlite3`
- The application uses a Python virtual environment at `/opt/venv/`

## Camera Access

The application is configured to allow camera access with appropriate security headers in the Apache configuration. 