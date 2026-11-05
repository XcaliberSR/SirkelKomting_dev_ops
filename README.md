# Proyek UTS Pengembangan dan Operasi - SirkelKomting

Aplikasi web sederhana berbasis Python Flask yang dikemas sebagai container image (Podman/Docker) dengan teknik **multi-stage build**, dijalankan sebagai **user non-root**, dan didistribusikan melalui **Docker Hub**.

## Identitas Kelompok

- **Nama Kelompok**: SirkelKomting
- **Mata Kuliah**: 13.DVOP.302 - Pengembangan dan Operasi
- **Kelas**: IF-A Sore
- **Dosen Pengampu**: Sunario Megawan, S.Kom., M.Kom.
- **Program Studi**: S-1 Teknik Informatika, Universitas Mikroskil
- **Semester / TA**: V / 2026-2027

| No | Nama | NIM | Peran |
|----|------|-----|-------|
| 1 | Cherish Evangeline | 241110597 | Project Lead & System Architect |
| 2 | Ethan Wilbert | 241110939 | Backend & Frontend Developer |
| 3 | Justin Wisely | 241110868 | DevOps Engineer (Containerization) |
| 4 | Richie Sanjiro | 241110236 | DevOps Engineer (Registry & QA) |

## Tautan Proyek

- **Docker Hub**: https://hub.docker.com/r/xcalibersr/sirkelkomting-app
- **GitHub**: https://github.com/XcaliberSR/SirkelKomting_dev_ops
- **Video Presentasi (8-12 menit)**: GANTI_LINK_VIDEO

## Fitur Aplikasi

| Endpoint | Fungsi |
|----------|--------|
| `/` | Halaman beranda, menampilkan isi Environment Variable `APP_MESSAGE` |
| `/students` | Halaman data mahasiswa (data in-memory, stateless) |
| `/health` | Health check dalam format JSON (status, versi, hostname container) |

- Logging otomatis setiap request HTTP (method, path, IP klien) ke stdout.
- Dijalankan dengan server WSGI produksi **gunicorn** (bukan server development Flask).
- Proses berjalan sebagai user non-root `appuser` (UID 1001).
- `HEALTHCHECK` bawaan image ke endpoint `/health`.

## Struktur Direktori

```text
SirkelKomting_dev_ops/
├── app.py               # Kode aplikasi Flask + logging
├── requirements.txt     # Flask + gunicorn
├── Containerfile        # Multi-stage build (builder -> runtime)
├── .containerignore     # Berkas yang tidak ikut ke build context (Podman)
├── .dockerignore        # Sama dengan .containerignore (untuk Docker)
├── .gitignore
├── README.md
└── templates/
    ├── index.html
    └── students.html
```

## Riwayat Versi Image

| Tag | Perubahan |
|-----|-----------|
| `1.0` | Single-stage, `python:3.12-slim`, server development Flask, non-root user |
| `1.1` / `latest` | Multi-stage build, gunicorn, HEALTHCHECK, LABEL OCI, hanya menyalin `app.py` dan `templates/` |

## Panduan Pengoperasian Container (Podman)

> Catatan WSL: jika muncul error `controller pids is not available`, tambahkan opsi `--cgroups=disabled` pada `podman run` (lihat Bab V laporan).

### 1. Build image

```bash
podman build --format docker -t sirkelkomting-app:latest .
```

`--format docker` diperlukan agar instruksi `HEALTHCHECK` tersimpan di image (format OCI bawaan Podman mengabaikannya).

Dengan Docker:

```bash
docker build -f Containerfile -t sirkelkomting-app:latest .
```

### 2. Melihat ukuran dan layer image

```bash
podman images sirkelkomting-app:latest
podman image history sirkelkomting-app:latest
```

### 3. Menjalankan container

```bash
podman run --cgroups=disabled -d --name sirkelkomting-web -p 8080:5000 `
  -e APP_MESSAGE="Selamat datang di Portal Informasi Mahasiswa - Kelompok SirkelKomting!" `
  sirkelkomting-app:latest
```

Akses di browser:

- Beranda: http://127.0.0.1:8080
- Data Mahasiswa: http://127.0.0.1:8080/students
- Health Check: http://127.0.0.1:8080/health

### 4. Pemeriksaan container

```bash
podman ps                                   # status container
podman logs sirkelkomting-web               # log request HTTP
podman inspect sirkelkomting-web            # metadata lengkap
podman inspect --format '{{.Config.User}}' sirkelkomting-web       # user = appuser
podman inspect --format '{{.Config.Env}}' sirkelkomting-web        # environment variable
podman exec sirkelkomting-web whoami        # verifikasi non-root
podman healthcheck run sirkelkomting-web    # jalankan health check manual
```

### 5. Siklus hidup container

```bash
podman stop sirkelkomting-web
podman start sirkelkomting-web
podman restart sirkelkomting-web
podman stop sirkelkomting-web
podman rm sirkelkomting-web
```

## Distribusi Image ke Docker Hub

### 1. Login

```bash
podman login docker.io
```

### 2. Tagging versi

```bash
podman tag localhost/sirkelkomting-app:latest docker.io/xcalibersr/sirkelkomting-app:latest
podman tag localhost/sirkelkomting-app:latest docker.io/xcalibersr/sirkelkomting-app:latest
```

### 3. Push

```bash
podman push docker.io/xcalibersr/sirkelkomting-app:latest
```

### 4. Pembuktian pull dan run ulang

```bash
# Hapus container dan image lokal
podman rm -f sirkelkomting-web
podman rmi localhost/sirkelkomting-app:latest docker.io/xcalibersr/sirkelkomting-app:latest docker.io/xcalibersr/sirkelkomting-app:latest

# Pull dari Docker Hub
podman pull docker.io/xcalibersr/sirkelkomting-app:latest

# Jalankan dari image hasil pull di port 8081
podman run --cgroups=disabled -d --name sirkelkomting-pulled -p 8081:5000 `
  -e APP_MESSAGE="Aplikasi berhasil berjalan dari image hasil pull Docker Hub!" `
  docker.io/xcalibersr/sirkelkomting-app:latest

# Verifikasi
podman exec sirkelkomting-pulled whoami
podman logs sirkelkomting-pulled
```

Akses hasil pull: http://127.0.0.1:8081

## Menjalankan Tanpa Container (development)

```bash
python -m venv .venv
.venv\Scripts\activate        # Windows  (Linux/WSL: source .venv/bin/activate)
pip install -r requirements.txt
python app.py
```
