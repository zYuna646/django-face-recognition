# Docker Setup for Django Face Recognition

This Docker setup provides an environment to run the Django Face Recognition project with SQLite3 database and Gunicorn, hosted behind a global Nginx server on the domain https://fer.zyuna646.tech/.

## Features

- Django web application with SQLite3 database
- Gunicorn WSGI server for production-ready Django serving
- Static files served through Nginx
- Integration with global Nginx server
- HTTPS support via Certbot-managed SSL certificates
- Easy deployment with setup script

## Prerequisites

- Docker and Docker Compose installed on your server
- Nginx configured on the server with Certbot for SSL
- Domain name (fer.zyuna646.tech) pointing to your server's IP address

## Setup Instructions

1. Clone the repository:
   ```
   git clone <repository-url>
   cd django-face-recognition
   ```

2. Configure Nginx:
   - Ensure the Nginx configuration at `/etc/nginx/sites-available/fer.zyuna646.tech` is properly set up
   - The configuration should proxy requests to `localhost:8000` and serve static/media files from the appropriate directories

3. Run the setup script:
   ```
   ./setup.sh
   ```
   
   The script will:
   - Create necessary directories for media and static files
   - Check if the .env file exists (if not, it will copy from env.example)
   - Ensure Docker Compose is installed
   - Build and start the containers

4. Reload Nginx to apply any configuration changes:
   ```
   sudo nginx -t && sudo systemctl reload nginx
   ```

5. Access the application at https://fer.zyuna646.tech/

## Environment Variables

You can configure the application by setting environment variables in the `.env` file:

- `DEBUG`: Set to "True" for development, "False" for production
- `SECRET_KEY`: Django's secret key (should be a long, random string)
- `ALLOWED_HOSTS`: Comma-separated list of allowed hosts

## File Persistence

The following data is persisted through Docker volumes:

- **Database**: `./db.sqlite3` - Your SQLite database file
- **Static Files**: `./staticfiles` - Collected static files served by Nginx
- **Media Files**: `./media` - User-uploaded media files
- **Source Static Files**: `./static` - Source static files for development

## Docker Configuration

- The application runs in a Docker container using host networking mode
- Gunicorn serves the Django application on port 8000
- Nginx proxies requests to the application and serves static/media files

## Maintenance

### Viewing Logs

```bash
docker compose -f docker-compose.prod.yml logs -f web
```

### Updating the Application

```bash
git pull
docker compose -f docker-compose.prod.yml up -d --build
sudo systemctl reload nginx
```

### Database Backups

To backup the SQLite database:

```bash
cp db.sqlite3 db.sqlite3.backup-$(date +%Y%m%d)
```

## Troubleshooting

- **Static files not loading**: Ensure the staticfiles directory exists and static files were collected during the build process.
- **Application not accessible**: Check if the Docker container is running with `docker ps` and if Nginx is properly configured.
- **Database errors**: Verify the SQLite database file exists and has proper permissions.
- **Nginx errors**: Check Nginx logs with `sudo tail -f /var/log/nginx/error.log`

## Security Notes

- The default SECRET_KEY in the docker-compose file is for development only. Always change it in production.
- SSL is managed by Certbot. Ensure certificates are regularly renewed.
- Consider implementing proper database backups for production use. 