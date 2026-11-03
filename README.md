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

## Panduan Pengoperasian Container (Podman / Docker)

### 1. Build Container Image
Menggunakan **Podman**:
```bash
podman build -t sirkelkomting-app:1.0 .
```
*(Atau Docker: `docker build -f Containerfile -t sirkelkomting-app:1.0 .`)*

### 2. Menjalankan Container
Menggunakan **Podman**:
```bash
podman run --cgroups=disabled -d --name sirkelkomting-web -p 8080:5000 -e APP_MESSAGE="Selamat datang di Portal Informasi Mahasiswa - Kelompok SirkelKomting!" sirkelkomting-app:1.0
```
*(Atau Docker: `docker run -d --name sirkelkomting-web -p 8080:5000 -e APP_MESSAGE="Selamat datang di Portal Informasi Mahasiswa - Kelompok SirkelKomting!" sirkelkomting-app:1.0`)*

Akses aplikasi melalui browser:
- Beranda: [http://127.0.0.1:8080](http://127.0.0.1:8080)
- Data Mahasiswa: [http://127.0.0.1:8080/students](http://127.0.0.1:8080/students)
- Health Check: [http://127.0.0.1:8080/health](http://127.0.0.1:8080/health)

### 3. Perintah Pemeriksaan Container (Podman)
- Melihat status container:
  ```bash
  podman ps
  ```
- Melihat logging container:
  ```bash
  podman logs sirkelkomting-web
  ```
- Memeriksa konfigurasi dan metadata container:
  ```bash
  podman inspect sirkelkomting-web
  ```
- Menjalankan perintah di dalam container (verifikasi non-root user `appuser`):
  ```bash
  podman exec sirkelkomting-web whoami
  ```
- Menghentikan dan menghapus container:
  ```bash
  podman stop sirkelkomting-web
  podman rm sirkelkomting-web
  ```

## Distribusi Image ke Container Registry (Docker Hub)

### 1. Login ke Docker Hub
```bash
podman login docker.io
```

### 2. Memberikan Tag Versi pada Image
```bash
podman tag localhost/sirkelkomting-app:1.0 docker.io/xcalibersr/sirkelkomting-app:1.0
```

### 3. Push Image ke Docker Hub
```bash
podman push docker.io/xcalibersr/sirkelkomting-app:1.0
```

### 4. Pembuktian Pull dan Menjalankan Kembali
```bash
# Hapus image lokal untuk pembuktian
podman rmi docker.io/xcalibersr/sirkelkomting-app:1.0

# Pull kembali dari registry
podman pull docker.io/xcalibersr/sirkelkomting-app:1.0

# Jalankan container dari image hasil pull (uji pada port 8081)
podman run --cgroups=disabled -d --name sirkelkomting-pulled -p 8081:5000 -e APP_MESSAGE="StudentHub berjalan dari image hasil pull Docker Hub!" docker.io/<username_dockerhub>/sirkelkomting-app:1.0
```
Akses aplikasi hasil pull melalui browser: [http://127.0.0.1:8081](http://127.0.0.1:8081)

