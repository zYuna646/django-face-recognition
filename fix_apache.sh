#!/bin/bash

echo "==== APACHE FIX TOOL ===="
echo "Tool ini akan memperbaiki masalah halaman default Apache"
echo ""

# Cek container berjalan
echo "Memeriksa container..."
if ! docker-compose ps | grep -q "django_face_recog.*Up"; then
  echo "Error: Container tidak berjalan!"
  echo "Memulai container..."
  docker-compose up -d
  sleep 5
fi

# Hapus halaman default Apache
echo "Menghapus halaman default Apache..."
docker-compose exec web rm -f /var/www/html/index.html

# Reset konfigurasi Apache
echo "Mereset konfigurasi Apache..."
docker-compose exec web a2dissite 000-default.conf
docker-compose exec web a2ensite fer.webapps.digital.conf

# Periksa konfigurasi
echo "Memeriksa konfigurasi Apache..."
docker-compose exec web apache2ctl configtest

# Restart Apache
echo "Merestart Apache..."
docker-compose exec web service apache2 restart

# Cek status Apache
echo "Status Apache:"
docker-compose exec web service apache2 status

# Cek apakah ada proses lain di port 80
echo "Memeriksa proses yang menggunakan port 80 di dalam container..."
docker-compose exec web netstat -tuln | grep ":80"

# Periksa log error
echo "Log error Apache:"
docker-compose exec web tail -n 20 /var/log/apache2/error.log

echo ""
echo "Perbaikan selesai. Silakan akses http://fer.webapps.digital"
echo "Jika masih muncul halaman default Apache, mungkin ada masalah dengan konfigurasi DNS atau routing."
echo "Coba juga akses dengan localhost:8080 untuk memastikan aplikasi berjalan dengan benar." 