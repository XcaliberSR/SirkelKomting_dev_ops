# 1. Base image yang stabil, resmi, dan ringan (Optimasi ukuran image)
FROM python:3.12-slim

# 2. Konfigurasi environment bawaan Python
# PYTHONDONTWRITEBYTECODE=1: Mencegah Python menulis file .pyc ke container
# PYTHONUNBUFFERED=1: Memastikan output log langsung dialirkan ke stdout (terbaca oleh podman/docker logs)
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

# 3. Menetapkan direktori kerja di dalam container
WORKDIR /app

# 4. Menyalin requirements.txt terlebih dahulu untuk memanfaatkan Docker/Podman layer caching
COPY requirements.txt .

# 5. Memasang dependensi tanpa cache pip agar ukuran image tetap minimal
RUN pip install --no-cache-dir -r requirements.txt

# 6. Aspek Keamanan: Membuat pengguna sistem non-root 'appuser'
RUN useradd --create-home --shell /bin/bash appuser

# 7. Menyalin source code aplikasi dengan hak milik pengguna 'appuser'
COPY --chown=appuser:appuser . .

# 8. Menjalankan proses container dengan hak akses non-root
USER appuser

# 9. Dokumentasi port yang didengarkan oleh aplikasi
EXPOSE 5000

# 10. Perintah utama saat container dijalankan
CMD ["python", "app.py"]
