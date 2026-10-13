# Project Memory — Antigravity Termux Installer

> **Repository**: [maoneart/antigravity-termux](https://github.com/maoneart/antigravity-termux)  
> **Author**: Hermawan (MaoneArt)

---

## 📌 Architecture & Installer Flow
1. **Target**: Native Termux di Android (Arsitektur `aarch64` / 64-bit ARM).
2. **Dependensi Kunci**:
   - `glibc-repo` harus dipasang SEBELUM `glibc` agar `apt` mengenali repo glibc.
   - `resolv-conf` & DNS fallback (`8.8.8.8`, `8.8.4.4`, `1.1.1.1`) di `$PREFIX/etc/resolv.conf`.
   - `ca-certificates` di `$PREFIX/etc/tls/cert.pem`.
   - `qemu-user-aarch64` otomatis dipasang jika CPU tidak memiliki instruksi `atomics` di `/proc/cpuinfo`.
3. **Penyimpanan Biner**:
   - `agy` & `agy.va39` diekstrak ke `$PREFIX/bin/` dengan izin `0755`.
   - Symlinks: `antigravity`, `antigrafity`.
4. **Proteksi Pipe**:
   - Menggunakan `DEBIAN_FRONTEND=noninteractive < /dev/null` agar aman saat dipanggil via `curl ... | bash`.

---

## 🚀 Perintah 1-Baris
```bash
curl -fsSL https://raw.githubusercontent.com/maoneart/antigravity-termux/main/kode.sh | bash
```
Atau:
```bash
curl -fsSL https://raw.githubusercontent.com/maoneart/antigravity-termux/main/install.sh | bash
```
