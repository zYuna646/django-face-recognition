# Docker Setup for Django Face Recognition

This Docker setup provides an environment to run the Django Face Recognition project with SQLite3, Gunicorn, and Apache.

## Architecture

```
Client → Apache (port 8080) → Gunicorn (port 3500) → Django Application
```

## Features

- Django web application
- SQLite3 database
- Gunicorn WSGI server for running the Django application
- Apache web server for serving static files and acting as a reverse proxy
- Python virtual environment for dependency isolation
- Port 8080 for web access
- Domain configuration for fer.webapps.digital

## Prerequisites

- Docker and Docker Compose installed on your server
- Domain (fer.webapps.digital) pointing to your server's IP address

## Setup Instructions

1. Clone the repository:
   ```
   git clone <repository-url>
   cd django-face-recognition
   ```

2. Modify the environment variables in docker-compose.yml if needed:
   - Set a strong SECRET_KEY
   - Add any additional ALLOWED_HOSTS

3. Deploy the application:
   ```
   ./deploy.sh
   ```

4. Access the application at http://fer.webapps.digital:8080/

## Project Structure

- `Dockerfile`: Container configuration for the Django application
- `docker-compose.yml`: Docker Compose configuration for easy deployment
- `apache/fer.webapps.digital.conf`: Apache virtual host configuration
- `supervisor/supervisord.conf`: Supervisor configuration to manage both Apache and Gunicorn
- `deploy.sh`: Deployment script

## Process Management

This setup uses Supervisor to manage two processes:
1. **Apache** - Handles static files and proxies dynamic requests to Gunicorn
2. **Gunicorn** - WSGI server that runs the Django application

## Python Virtual Environment

The application runs inside a Python virtual environment located at `/opt/venv` within the container. This provides isolation from the system Python and helps manage dependencies more effectively.

## Database Management

The SQLite database is mounted as a volume, so data persists across container restarts. The database file is located at:
```
./db.sqlite3
```

## Media Files

Uploaded media files are stored in the media directory which is mounted as a volume:
```
./media
```

## Static Files

Static files are served directly by Apache from the staticfiles directory:
```
./staticfiles
```

## Troubleshooting

- Check Docker logs:
  ```
  docker-compose logs
  ```

- Check Apache logs:
  ```
  docker-compose exec web cat /var/log/apache2/error.log
  ```

- Check Gunicorn logs:
  ```
  docker-compose exec web cat /var/log/gunicorn.log
  ```

- Access the virtual environment inside the container:
  ```
  docker-compose exec web /opt/venv/bin/python -V
  ``` 