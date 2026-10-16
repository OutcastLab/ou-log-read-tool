#!/usr/bin/env bash
# Installer for ou-log-read-tool
#   sudo ./install.sh              install to /usr/local/bin
#   sudo ./install.sh uninstall    remove it
# PREFIX can be overridden:  PREFIX=/opt/bin ./install.sh
set -e

TOOL="ou-log-read-tool"
PREFIX="${PREFIX:-/usr/local/bin}"
HERE="$(cd "$(dirname "$0")" && pwd)"

if [ "$(id -u)" -ne 0 ] && [ "$PREFIX" = "/usr/local/bin" ]; then
    echo "[!] Run as root:  sudo ./install.sh"
    exit 1
fi

if [ "$1" = "uninstall" ]; then
    rm -f "$PREFIX/$TOOL"
    echo "[+] Removed $PREFIX/$TOOL"
    exit 0
fi

if [ ! -f "$HERE/$TOOL" ]; then
    echo "[!] $TOOL not found next to install.sh"
    exit 1
fi

if ! command -v python3 >/dev/null 2>&1; then
    echo "[!] python3 is required"
    exit 1
fi

mkdir -p "$PREFIX"
install -m 755 "$HERE/$TOOL" "$PREFIX/$TOOL"
echo "[+] Installed to $PREFIX/$TOOL"
echo "[+] Try:  sudo $TOOL -h"
