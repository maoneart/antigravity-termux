# Google Antigravity AI — Termux 1-Line Installer

[![Termux](https://img.shields.io/badge/Platform-Termux%20Android-black?logo=android&logoColor=green)](https://termux.dev)
[![Architecture](https://img.shields.io/badge/Arch-aarch64%20%2F%20arm64-blue)](https://github.com/maoneart/antigravity-termux)
[![Shell](https://img.shields.io/badge/Script-Bash-4EAA25?logo=gnu-bash&logoColor=white)](https://github.com/maoneart/antigravity-termux)
[![Author](https://img.shields.io/badge/Author-MaoneArt-purple)](https://maoneart.my.id)
[![License](https://img.shields.io/badge/License-MIT-orange.svg)](LICENSE)

> **Skrip installer otomatis 1-baris untuk memasang Google Antigravity AI CLI (`agy`) langsung di Android melalui Termux.**

---

## ⚡ Instalasi Cepat (1-Baris Perintah)

Buka aplikasi **Termux** di HP Android Anda, lalu salin dan jalankan perintah berikut:

```bash
curl -fsSL https://raw.githubusercontent.com/maoneart/antigravity-termux/main/kode.sh | bash
```

*Atau menggunakan alias `install.sh`:*

```bash
curl -fsSL https://raw.githubusercontent.com/maoneart/antigravity-termux/main/install.sh | bash
```

Skrip akan secara otomatis:
1. Mendeteksi arsitektur perangkat Anda (wajib `aarch64` / 64-bit ARM).
2. Memasang dependensi yang dibutuhkan (`glibc-repo`, `glibc`, `ca-certificates`, `resolv-conf`, `tar`, `curl`).
3. Mendeteksi dukungan hardware LSE atomics (dan otomatis memasang `qemu-user-aarch64` jika chipset belum mendukung LSE).
4. Mengunduh dan mengekstrak engine biner Antigravity CLI standalone ke `$PREFIX/bin/agy`.
5. Menyiapkan symlink `antigravity` dan `antigrafity` untuk kemudahan pemanggilan.
6. Memverifikasi biner agar siap digunakan seketika.

---

## 🚀 Cara Menggunakan

### 1. Memulai Sesi & Login Pertama Kali
Setelah instalasi selesai, cukup ketik:

```bash
agy
```
*(atau bisa juga mengetik `antigravity`)*

Pada peluncuran pertama:
1. Terminal akan menampilkan **Tautan Login Google** serta sebuah **Kode Perangkat (Device Code)**.
2. Buka tautan tersebut di browser (Chrome / browser default Anda).
3. Masuk menggunakan akun Google Anda dan konfirmasi kodenya.
4. Terminal Termux akan otomatis terhubung dan siap menerima instruksi coding!

### 2. Perintah yang Tersedia

| Perintah | Deskripsi |
| :--- | :--- |
| `agy` | Memulai sesi interaktif pair-programming Antigravity AI |
| `antigravity` | Alias lengkap untuk menjalankan Antigravity AI |
| `agy --help` | Menampilkan seluruh opsi parameter dan sub-perintah |
| `agy update` | Memeriksa dan memperbarui engine Antigravity ke versi terbaru |

---

## 📱 Kebutuhan Sistem

- **Aplikasi Termux**: Versi terbaru (direkomendasikan dari [F-Droid](https://f-droid.org/packages/com.termux/) atau GitHub Termux, hindari versi Play Store yang usang).
- **Arsitektur CPU**: `aarch64` (ARM 64-bit). Sebagian besar HP Android modern keluaran 2017 ke atas sudah mendukung arsitektur ini.
- **Ruang Penyimpanan**: Minimal ~250 MB ruang kosong untuk paket glibc dan engine biner.
- **Koneksi Internet**: Diperlukan saat instalasi dan saat AI berkomunikasi dengan Google Cloud.

---

## 💡 Tips & Konfigurasi Tambahan

### Memberikan Panduan Khusus Proyek (`GEMINI.md`)
Antigravity AI membaca berkas aturan `GEMINI.md` di direktori proyek atau di home directory (`$HOME/GEMINI.md`). Anda dapat menentukan:
- Bahasa respon (misal: Bahasa Indonesia).
- Gaya penulisan kode (Tailwind CSS, glassmorphism, arsitektur MVC, dll).
- Larangan dan batasan scope modifikasi.

---

## ❓ Troubleshooting

<details>
<summary><b>1. Error: "CPU does not support LSE atomics"</b></summary>

Chipset Snapdragon atau MediaTek generasi tertentu belum mendukung instruksi LSE atomics secara native. Skrip `kode.sh` kami secara otomatis mengatasinya dengan memasang `qemu-user-aarch64`. Jika Anda memasang manual, jalankan:
```bash
pkg install -y qemu-user-aarch64
```
</details>

<details>
<summary><b>2. Error: "Could not resolve host" atau DNS gagal</b></summary>

Pastikan paket `resolv-conf` terpasang agar biner glibc dapat menerjemahkan domain internet:
```bash
pkg install -y resolv-conf
```
</details>

<details>
<summary><b>3. Muncul pesan "Permission denied" saat menjalankan skrip</b></summary>

Pastikan Anda menjalankan skrip melalui bash pipe:
```bash
bash <(curl -fsSL https://raw.githubusercontent.com/maoneart/antigravity-termux/main/kode.sh)
```
</details>

---

## 👨‍💻 Kontribusi & Author

- **Author**: Hermawan ([MaoneArt](https://maoneart.my.id))
- **Website**: [maoneart.my.id](https://maoneart.my.id)
- **Engine Upstream Credit**: Google DeepMind / Antigravity CLI Termux Standalone Project.

---

## 📄 Lisensi

Proyek pembungkus installer ini didistribusikan di bawah lisensi [MIT License](LICENSE).
