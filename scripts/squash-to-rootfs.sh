#!/usr/bin/env bash

# Check argument
if [ -z "$1" ]; then
  echo "Usage: $0 <squashfs_file>"
  exit 1
fi

SQUASHFS="$1"
OUTDIR="squashfs-root"
OUTTAR="rootfs.tar.gz"

# Make sure squashfs-tools is installed
command -v unsquashfs >/dev/null 2>&1 || {
  echo "Error: unsquashfs not found. Install squashfs-tools."; exit 1;
}

echo "[+] Extracting $SQUASHFS ..."
sudo unsquashfs -d "$OUTDIR" "$SQUASHFS"

echo "[+] Creating $OUTTAR ..."
sudo tar -czf "$OUTTAR" -C "$OUTDIR" .

echo "[+] Done: $OUTTAR created"

