# =====================================================================
# Containerfile - Proyek UTS Pengembangan dan Operasi (13.DVOP.302)
# Kelompok SirkelKomting
# Teknik: multi-stage build + base image minimal (small footprint)
# =====================================================================

# ---------- STAGE 1: builder -----------------------------------------
# Stage ini hanya dipakai untuk memasang dependensi Python.
# pip, cache, dan file sementara instalasi TIDAK ikut ke image akhir.
FROM docker.io/library/python:3.12-slim AS builder

ENV PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1

WORKDIR /build

# Salin requirements.txt dulu agar layer instalasi dependensi ter-cache
# (layer ini tidak dibangun ulang selama requirements.txt tidak berubah)
COPY requirements.txt .

# Pasang dependensi ke folder terpisah (/install) agar mudah disalin
RUN pip install --prefix=/install -r requirements.txt


# ---------- STAGE 2: runtime (image akhir) ---------------------------
FROM docker.io/library/python:3.12-slim AS runtime

# Metadata image standar OCI
LABEL org.opencontainers.image.title="sirkelkomting-app" \
      org.opencontainers.image.description="Portal Informasi Mahasiswa - Proyek UTS Pengembangan dan Operasi" \
      org.opencontainers.image.version="1.1" \
      org.opencontainers.image.authors="Kelompok SirkelKomting" \
      org.opencontainers.image.source="https://github.com/GANTI_USERNAME_GITHUB/SirkelKomting_dev_ops"

# PYTHONDONTWRITEBYTECODE=1 : tidak menulis file .pyc
# PYTHONUNBUFFERED=1        : log langsung ke stdout (terbaca podman logs)
# APP_MESSAGE               : nilai bawaan, dapat ditimpa dengan -e saat run
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    APP_MESSAGE="Selamat datang di Portal Informasi Mahasiswa - Kelompok SirkelKomting!"

# Keamanan: user non-root dengan UID tetap dan tanpa shell login
RUN useradd --uid 1001 --create-home --shell /usr/sbin/nologin appuser

WORKDIR /app

# Ambil HANYA hasil instalasi dependensi dari stage builder
COPY --from=builder /install /usr/local

# Salin HANYA berkas yang dibutuhkan aplikasi (bukan seluruh folder proyek)
COPY --chown=appuser:appuser app.py .
COPY --chown=appuser:appuser templates/ ./templates/

# Jalankan proses sebagai non-root
USER appuser

EXPOSE 5000

# Pemeriksaan kesehatan otomatis ke endpoint /health
# (Podman: build dengan --format docker agar HEALTHCHECK tersimpan)
HEALTHCHECK --interval=30s --timeout=3s --start-period=10s --retries=3 \
  CMD python -c "import urllib.request; urllib.request.urlopen('http://127.0.0.1:5000/health', timeout=2)" || exit 1

# Server WSGI produksi (gunicorn) menggantikan server development Flask
CMD ["gunicorn", "--bind", "0.0.0.0:5000", "--workers", "2", "--access-logfile", "-", "app:app"]
