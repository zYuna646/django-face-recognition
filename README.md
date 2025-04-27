# Django Face Recognition Application

Aplikasi pengenalan wajah menggunakan Django dan TensorFlow.

## Persiapan Deployment

### 1. Clone Repository

```bash
git clone <repository-url>
cd django-face-recognition
```

### 2. Siapkan Direktori dan Izin

```bash
# Buat direktori yang diperlukan
mkdir -p static/CACHE/css static/img static/js static/models static/src upload

# Atur izin
chmod -R 755 static upload
```

### 3. Build dan Jalankan Docker Container

```bash
# Build dan jalankan container
docker-compose up -d --build
```

### 4. Konfigurasi Apache

```bash
# Salin file konfigurasi Apache
cp apache-conf/000-default.conf /etc/apache2/sites-available/fer.webapps.digital.conf
cp apache-conf/apache2.conf /etc/apache2/conf-available/fer.conf

# Aktifkan konfigurasi
a2ensite fer.webapps.digital.conf
a2enconf fer.conf
a2enmod proxy proxy_http headers
systemctl restart apache2
```

### 5. Siapkan Script Pemeliharaan

```bash
# Salin script pemeliharaan
cp docker-entrypoint/maintain-static.sh /usr/local/bin/
chmod +x /usr/local/bin/maintain-static.sh
```

### 6. Setelah Container Restart

Jika container di-restart dan file static hilang, jalankan:

```bash
/usr/local/bin/maintain-static.sh
```

## Troubleshooting

### Masalah Static Files

Periksa log Apache:
```bash
tail -n 50 /var/log/apache2/error.log
```

Periksa izin direktori:
```bash
ls -la static/
ls -la static/CACHE/css/
```

Jalankan script pemeliharaan:
```bash
/usr/local/bin/maintain-static.sh
```

### Masalah Upload Gambar

Pastikan direktori upload memiliki izin yang benar:
```bash
chmod -R 755 upload/
chown -R www-data:www-data upload/
```

## Struktur Volume

- `static`: direktori untuk file static (CSS, JS, gambar)
- `upload`: direktori untuk file media yang diunggah pengguna
- `db.sqlite3`: file database

Volume ini di-mount ke container Docker:
- `./static:/app/static:rw`
- `./static:/app/staticfiles:rw`
- `./upload:/app/media:rw` 