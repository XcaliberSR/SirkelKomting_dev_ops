import os
import logging
from flask import Flask, render_template, jsonify, request

app = Flask(__name__)

# Konfigurasi logging standar ke stdout (agar terbaca langsung di docker logs)
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(message)s"
)

# Environment Variable sesuai ketentuan tugas (minimal 1)
# Nilai default disediakan jika environment variable belum diatur di sistem
APP_MESSAGE = os.getenv(
    "APP_MESSAGE",
    "Selamat datang di Portal Informasi Mahasiswa - Kelompok SirkelKomting!"
)

# Data contoh mahasiswa (Stateless in-memory)
STUDENTS_DATA = [
    {"id": "2024001", "name": "Aditya Pratama", "major": "Teknik Informatika", "semester": 4},
    {"id": "2024002", "name": "Budi Santoso", "major": "Sistem Informasi", "semester": 4},
    {"id": "2024003", "name": "Citra Lestari", "major": "Teknik Komputer", "semester": 2},
    {"id": "2024004", "name": "Dewi Anggraini", "major": "Teknik Informatika", "semester": 6},
]

# Middleware logging setiap menerima request HTTP
@app.before_request
def log_request_info():
    client_ip = request.remote_addr
    method = request.method
    path = request.path
    app.logger.info(f"Request Diterima: {method} {path} | Dari IP: {client_ip}")

# Endpoint 1: Beranda (/)
@app.route("/")
def home():
    # Ambil nilai terbaru dari environment variable jika ada perubahan saat runtime
    current_message = os.getenv("APP_MESSAGE", APP_MESSAGE)
    return render_template(
        "index.html",
        app_message=current_message,
        group_name="SirkelKomting"
    )

# Endpoint 2: Data Mahasiswa (/students)
@app.route("/students")
def students():
    return render_template(
        "students.html",
        students=STUDENTS_DATA,
        group_name="SirkelKomting"
    )

# Endpoint Tambahan: Health Check (/health)
@app.route("/health")
def health():
    return jsonify({
        "status": "healthy",
        "application": "SirkelKomting DevOps Portal",
        "version": "1.0.0"
    })

if __name__ == "__main__":
    # Host 0.0.0.0 agar aplikasi dapat diakses melalui port mapping container
    app.run(host="0.0.0.0", port=5000, debug=False)
