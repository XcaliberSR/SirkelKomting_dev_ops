# Proyek UTS DevOps - SirkelKomting

Aplikasi web sederhana berbasis Python Flask yang dikemas menggunakan container (Docker/Podman) untuk memenuhi tugas Ujian Tengah Semester (UTS).

## Identitas Kelompok
- **Nama Kelompok**: SirkelKomting
- **Mata Kuliah**: DevOps / Praktikum Sistem Operasi / Cloud
- **Tahun**: 2026

## Fitur Aplikasi
- Minimal 2 endpoint halaman web:
  - `/` : Halaman Beranda (membaca Environment Variable `APP_MESSAGE`).
  - `/students` : Halaman Data Mahasiswa.
  - `/health` : Endpoint status kesehatan aplikasi (JSON format).
- Logging otomatis setiap menerima request HTTP.
- Dijalankan dengan pengguna non-root (`appuser`) untuk keamanan.

## Struktur Direktori
```text
SirkelKomting_dev_ops/
├── app.py
├── requirements.txt
├── Containerfile
├── .dockerignore
├── .gitignore
├── README.md
└── templates/
    ├── index.html
    └── students.html
```

## Panduan Pengoperasian Container

### 1. Build Container Image
```bash
docker build -f Containerfile -t sirkelkomting-app:1.0 .
```

### 2. Menjalankan Container
```bash
docker run -d --name sirkelkomting-web -p 8080:5000 -e APP_MESSAGE="Selamat datang di StudentHub - Kelompok SirkelKomting!" sirkelkomting-app:1.0
```
Akses aplikasi melalui browser: [http://localhost:8080](http://localhost:8080)

### 3. Perintah Pemeriksaan Container
- Melihat status container:
  ```bash
  docker ps
  ```
- Melihat logging container:
  ```bash
  docker logs sirkelkomting-web
  ```
- Memeriksa konfigurasi dan metadata container:
  ```bash
  docker inspect sirkelkomting-web
  ```
- Menjalankan perintah di dalam container (verifikasi non-root user):
  ```bash
  docker exec sirkelkomting-web whoami
  ```
- Menghentikan dan menghapus container:
  ```bash
  docker stop sirkelkomting-web
  docker rm sirkelkomting-web
  ```

## Distribusi Image (Docker Hub Registry)
```bash
# Tag image sesuai nama repository Docker Hub
docker tag sirkelkomting-app:1.0 <dockerhub_username>/sirkelkomting-app:1.0

# Push ke Docker Hub
docker push <dockerhub_username>/sirkelkomting-app:1.0

# Pull dan uji kembali
docker pull <dockerhub_username>/sirkelkomting-app:1.0
docker run -d --name sirkelkomting-pulled -p 8081:5000 <dockerhub_username>/sirkelkomting-app:1.0
```
