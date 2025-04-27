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

## Port Configuration

The application uses:
- Port 80 inside the Docker container (Apache)
- Port 8080 on the host machine

If port 8080 is already in use on your host, you can change it in the `docker-compose.yml` file:
```yaml
ports:
  - "YOUR_DESIRED_PORT:80"
```

## Deployment Process

The deployment script performs the following steps:
1. Checks if port 8080 is already in use
2. Cleans up Docker resources (removes old containers, volumes, and cache)
3. Builds the Docker image fresh (no-cache)
4. Starts the container
5. Applies database migrations
6. Configures Apache to serve the site at fer.webapps.digital
   - Creates Apache config file named `fer.webapps.digital.conf`
   - Disables the default site
   - Enables the new site
7. Sets proper permissions for static files

## File Structure

- `Dockerfile`: Defines the container build process
- `docker-compose.yml`: Defines the services and environment
- `apache/django.conf`: Apache virtual host configuration template
- `deploy.sh`: Deployment helper script

## Important Notes

- Static files are served from `/app/staticfiles/` with proper permissions
- Media files are served from `/app/media/` with proper permissions
- Upload files are served from `/app/upload/` with proper permissions
- Database is SQLite3 located at `/app/db.sqlite3`
- The application uses a Python virtual environment at `/opt/venv/`
- Apache is configured to serve the site with fer.webapps.digital.conf 
- Default site (000-default.conf) is disabled
- All static content is configured to be properly accessible
- If accessing locally, use http://localhost:8080

## Camera Access

The application is configured to allow camera access with appropriate security headers in the Apache configuration. 