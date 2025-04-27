#!/bin/bash
# Script untuk memastikan file static tetap tersedia

# Pastikan direktori ada
mkdir -p /root/django-face-recognition/static/CACHE/css
mkdir -p /root/django-face-recognition/static/img
mkdir -p /root/django-face-recognition/static/js
mkdir -p /root/django-face-recognition/static/models
mkdir -p /root/django-face-recognition/static/src
mkdir -p /root/django-face-recognition/upload

# Salin file static dari container ke host
docker cp $(docker ps -qf "name=web"):/app/static/. /root/django-face-recognition/static/
docker cp $(docker ps -qf "name=web"):/app/staticfiles/. /root/django-face-recognition/static/

# Pastikan ada file CSS
touch /root/django-face-recognition/static/CACHE/css/output.53e39e3c3985.css

# Atur izin yang benar
chmod -R 755 /root/django-face-recognition/static
chmod -R 755 /root/django-face-recognition/upload
find /root/django-face-recognition/static -type f -exec chmod 644 {} \;
find /root/django-face-recognition/upload -type f -exec chmod 644 {} \;
chown -R www-data:www-data /root/django-face-recognition/static
chown -R www-data:www-data /root/django-face-recognition/upload

# Restart Apache
systemctl restart apache2

echo "Static files telah diperbarui." 