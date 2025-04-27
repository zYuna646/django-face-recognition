# Django Face Recognition Application with Apache and Docker

This repository contains a Django application for face recognition with a Docker setup using Apache as the web server.

## Environment Setup

The application is configured to be hosted at `http://fer.webapps.digital/` using Apache.

## Features

- Uses virtual environment inside Docker for Python dependencies
- Uses SQLite database
- Apache web server configuration
- Properly configured camera and upload permissions
- Static files served by Apache

## Getting Started

### Prerequisites

- Docker and Docker Compose installed on your system
- Domain name pointed to your server IP (fer.webapps.digital)

### Installation and Setup

1. Clone this repository:
   ```
   git clone <repository-url>
   cd <repository-directory>
   ```

2. Build and start the Docker containers:
   ```
   docker-compose up -d
   ```

3. Access the application at http://fer.webapps.digital:8080/ or http://localhost:8080/

## Configuration

### Environment Variables

You can modify the following environment variables in the `docker-compose.yml` file:

- `DEBUG`: Set to `False` for production
- `ALLOWED_HOSTS`: Comma-separated list of allowed hosts
- `SECRET_KEY`: Django secret key
- `SQLITE_DB_PATH`: Path to SQLite database

## Directory Structure

- `/app`: Root directory of the Django application
- `/app/static`: Static files
- `/app/media`: Media files
- `/app/upload`: Upload directory for files

## Camera Permissions

The application has been configured to allow camera access through:
- Custom Content Security Policy (CSP) headers
- Apache configuration for CORS

## Database

The application uses SQLite database which is stored in the root directory as `db.sqlite3`. This file is mounted as a volume in the Docker container to ensure data persistence.

## Static Files

Static files are collected during the Docker build process and served by Apache from the `/app/staticfiles` directory.

## Troubleshooting

If you encounter issues with camera access or file uploads, check:
1. Apache logs: `/var/log/apache2/error.log` inside the container
2. Make sure the permissions are set correctly for upload and media directories
3. Verify that the CSP headers are correctly configured in Django settings and Apache

## Port Configuration

The application is configured to run on port 8080 to avoid conflicts with other services that might be using port 80. If you need to change this port, modify the `ports` section in your `docker-compose.yml` file.

## License

[Specify your license here] 