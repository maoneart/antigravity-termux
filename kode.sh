#!/usr/bin/env bash
# ==============================================================================
#  MaoneArt Antigravity AI Installer for Android Termux
#  Repository : https://github.com/maoneart/antigravity-termux
#  Author     : Hermawan (MaoneArt) - https://maoneart.my.id
# ==============================================================================
set -Eeuo pipefail

# ANSI Colors
CYAN="\033[1;36m"
GREEN="\033[1;32m"
YELLOW="\033[1;33m"
RED="\033[1;31m"
MAGENTA="\033[1;35m"
BOLD="\033[1m"
DIM="\033[2m"
RESET="\033[0m"

# Header Banner
print_banner() {
  clear 2>/dev/null || true
  printf "%b" "${CYAN}"
  cat << "EOF"
  __  __                         _         _   
 |  \/  | __ _  ___  _ __   ___ / \   _ __| |_ 
 | |\/| |/ _` |/ _ \| '_ \ / _ // _ \ | '__| __|
 | |  | | (_| | (_) | | | |  __// ___ \| |  | |_ 
 |_|  |_|\__,_|\___/|_| |_|\___/_/   \_\_|   \__|
EOF
  printf "%b" "${RESET}"
  printf " %bGoogle Antigravity AI — Termux 1-Line Installer%b\n" "${BOLD}${MAGENTA}" "${RESET}"
  printf " %bCrafted by MaoneArt (https://maoneart.my.id)%b\n\n" "${DIM}" "${RESET}"
}

info() {
  printf " %b[i]%b %s\n" "${CYAN}" "${RESET}" "$1"
}

success() {
  printf " %b[✓]%b %s\n" "${GREEN}" "${RESET}" "$1"
}

warn() {
  printf " %b[!]%b %s\n" "${YELLOW}" "${RESET}" "$1"
}

error() {
  printf " %b[✗]%b %s\n" "${RED}" "${RESET}" "$1" >&2
}

# 1. Environment & Architecture Validation
validate_env() {
  if [[ -z "${PREFIX:-}" || ! -d "${PREFIX:-}" ]]; then
    error "Skrip ini dirancang khusus untuk lingkungan native Termux di Android."
    exit 1
  fi

  ARCH="$(uname -m)"
  if [[ "$ARCH" != "aarch64" && "$ARCH" != "arm64" ]]; then
    error "Arsitektur CPU '$ARCH' tidak didukung. Antigravity di Termux membutuhkan arsitektur aarch64 (64-bit ARM)."
    exit 1
  fi
  success "Lingkungan Termux terverifikasi ($ARCH)."
}

# 2. Automated Dependency Installation
install_dependencies() {
  info "Memeriksa paket & dependensi sistem..."

  local BASE_PKGS=()

  command -v curl >/dev/null 2>&1 || BASE_PKGS+=("curl")
  command -v tar  >/dev/null 2>&1 || BASE_PKGS+=("tar")

  # Check ca-certificates
  if [[ ! -s "$PREFIX/etc/tls/cert.pem" && ! -s "$PREFIX/etc/ssl/certs/ca-certificates.crt" ]]; then
    BASE_PKGS+=("ca-certificates")
  fi

  # Check resolv-conf
  if [[ ! -r "$PREFIX/etc/resolv.conf" ]]; then
    BASE_PKGS+=("resolv-conf")
  fi

  # Check LSE atomics & QEMU requirement
  if ! grep -q "atomics" /proc/cpuinfo 2>/dev/null; then
    if ! command -v qemu-aarch64 >/dev/null 2>&1; then
      warn "CPU tidak memiliki dukungan hardware LSE atomics. Menyiapkan emulator qemu-user-aarch64..."
      BASE_PKGS+=("qemu-user-aarch64")
    fi
  fi

  if [ ${#BASE_PKGS[@]} -gt 0 ]; then
    info "Menginstal paket dasar yang dibutuhkan: ${BASE_PKGS[*]}..."
    DEBIAN_FRONTEND=noninteractive pkg install -y "${BASE_PKGS[@]}" < /dev/null || \
    DEBIAN_FRONTEND=noninteractive apt-get install -y "${BASE_PKGS[@]}" < /dev/null
  fi

  # 2b. Glibc Check: glibc-repo MUST be installed before glibc package can be found
  if [[ ! -x "$PREFIX/glibc/lib/ld-linux-aarch64.so.1" ]]; then
    info "Menyiapkan runtime glibc untuk Termux..."
    if [[ ! -f "$PREFIX/etc/apt/sources.list.d/glibc.list" ]]; then
      info "Mengaktifkan repositori glibc-repo..."
      DEBIAN_FRONTEND=noninteractive pkg install -y glibc-repo < /dev/null || \
      DEBIAN_FRONTEND=noninteractive apt-get install -y glibc-repo < /dev/null
      pkg update -y < /dev/null || true
    fi
    info "Memasang paket glibc..."
    DEBIAN_FRONTEND=noninteractive pkg install -y glibc < /dev/null || \
    DEBIAN_FRONTEND=noninteractive apt-get install -y glibc < /dev/null
  fi

  # 2c. Pastikan resolv.conf valid agar DNS tidak gagal
  if [[ ! -s "$PREFIX/etc/resolv.conf" ]]; then
    mkdir -p "$PREFIX/etc"
    printf "nameserver 8.8.8.8\nnameserver 8.8.4.4\nnameserver 1.1.1.1\n" > "$PREFIX/etc/resolv.conf"
  fi

  # 2d. Pastikan symlink cert.pem tersedia jika menggunakan cert standar
  if [[ ! -s "$PREFIX/etc/tls/cert.pem" && -s "$PREFIX/etc/ssl/certs/ca-certificates.crt" ]]; then
    mkdir -p "$PREFIX/etc/tls"
    cp -f "$PREFIX/etc/ssl/certs/ca-certificates.crt" "$PREFIX/etc/tls/cert.pem" 2>/dev/null || true
  fi

  success "Semua dependensi sistem lengkap dan siap."
}

# 3. Download & Deploy Antigravity Standalone Binaries
install_engine() {
  local REPO="wallentx/antigravity-cli-termux"
  local DOWNLOAD_URL="https://github.com/${REPO}/releases/latest/download/antigravity-termux-standalone.tar.gz"
  local TMP_TAR="$PREFIX/tmp/antigravity-termux-standalone.tar.gz"
  local EXTRACT_DIR="$PREFIX/tmp/.agy-extract-maoneart"
  local BIN_DIR="$PREFIX/bin"

  mkdir -p "$PREFIX/tmp" "$BIN_DIR"

  info "Mengunduh engine Google Antigravity AI untuk Termux..."
  if ! curl -fL --progress-bar "$DOWNLOAD_URL" -o "$TMP_TAR"; then
    error "Gagal mengunduh bundle Antigravity dari server rilis."
    exit 1
  fi

  info "Mengekstrak berkas biner..."
  rm -rf "$EXTRACT_DIR"
  mkdir -p "$EXTRACT_DIR"
  tar -xzf "$TMP_TAR" -C "$EXTRACT_DIR" agy agy.va39

  # Backup old binaries if existing
  [[ -f "$BIN_DIR/agy" ]] && mv -f "$BIN_DIR/agy" "$BIN_DIR/agy.old" 2>/dev/null || true
  [[ -f "$BIN_DIR/agy.va39" ]] && mv -f "$BIN_DIR/agy.va39" "$BIN_DIR/agy.va39.old" 2>/dev/null || true

  # Install binaries with executable permissions
  cp -f "$EXTRACT_DIR/agy" "$BIN_DIR/agy"
  cp -f "$EXTRACT_DIR/agy.va39" "$BIN_DIR/agy.va39"
  chmod 755 "$BIN_DIR/agy" "$BIN_DIR/agy.va39"

  # Clean temporary files
  rm -rf "$EXTRACT_DIR" "$TMP_TAR"
  success "Engine Antigravity CLI berhasil dipasang ke $BIN_DIR/agy."

  # Setup friendly symlinks
  ln -sf "$BIN_DIR/agy" "$BIN_DIR/antigravity"
  ln -sf "$BIN_DIR/agy" "$BIN_DIR/antigrafity"
  chmod 755 "$BIN_DIR/antigravity" "$BIN_DIR/antigrafity" 2>/dev/null || true
  success "Symlink alias dibuat: 'antigravity' & 'antigrafity'."

  # Refresh shell command lookup hash table
  hash -r 2>/dev/null || true
}

# 4. Verification & First-Run Setup
verify_install() {
  info "Memverifikasi integritas instalasi..."
  local VER_OUTPUT
  if VER_OUTPUT=$("$PREFIX/bin/agy" --version 2>/dev/null); then
    success "Verifikasi berhasil: Antigravity CLI versi ${BOLD}${VER_OUTPUT}${RESET}"
  else
    warn "Biner terpasang namun belum dapat menampilkan versi langsung. Silakan coba jalankan 'agy'."
  fi
}

# 5. Completion Summary & Getting Started
show_completion() {
  printf "\n%b" "${GREEN}══════════════════════════════════════════════════════════════════════════${RESET}\n"
  printf " %bSELAMAT! Google Antigravity AI Sukses Terpasang di Termux!%b\n" "${BOLD}${GREEN}" "${RESET}"
  printf "%b" "${GREEN}══════════════════════════════════════════════════════════════════════════${RESET}\n\n"

  printf " %bLangkah Memulai:%b\n" "${BOLD}${CYAN}" "${RESET}"
  printf "  1. Jalankan perintah: %bagy%b atau %bantigravity%b\n" "${BOLD}${YELLOW}" "${RESET}" "${BOLD}${YELLOW}" "${RESET}"
  printf "  2. Buka link login Google yang muncul di browser HP Anda.\n"
  printf "  3. Masukkan kode otentikasi untuk menghubungkan akun Google Anda.\n"
  printf "  4. Mulai coding dan instruksikan AI langsung di Termux Android Anda!\n\n"

  printf " %bPintasan Perintah Penting:%b\n" "${BOLD}${CYAN}" "${RESET}"
  printf "  • %bagy%b           : Mulai sesi interaktif pair-programming AI\n" "${GREEN}" "${RESET}"
  printf "  • %bagy --help%b    : Menampilkan bantuan dan opsi parameter lengkap\n" "${GREEN}" "${RESET}"
  printf "  • %bagy update%b    : Memperbarui CLI Antigravity ke versi terbaru\n\n" "${GREEN}" "${RESET}"

  printf " %bDokumentasi & Tutorial Lengkap:%b\n" "${BOLD}${CYAN}" "${RESET}"
  printf "  • Blog & Panduan : %bhttps://maoneart.my.id%b\n" "${BOLD}${MAGENTA}" "${RESET}"
  printf "  • GitHub Repo    : %bhttps://github.com/maoneart/antigravity-termux%b\n\n" "${BOLD}${MAGENTA}" "${RESET}"
}

main() {
  print_banner
  validate_env
  install_dependencies
  install_engine
  verify_install
  show_completion
}

main "$@"
