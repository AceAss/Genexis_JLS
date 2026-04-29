#!/bin/bash

echo "================================="
echo " Installing Genexis Toolkit 🧬"
echo "================================="

# Get project root directory
BASE_DIR="$(cd "$(dirname "$0")" && pwd)"

# Check if genexis executable exists
if [[ ! -f "$BASE_DIR/bin/genexis" ]]; then
  echo "Error: bin/genexis not found"
  exit 1
fi

# Make scripts executable
echo "[+] Setting permissions..."
chmod +x "$BASE_DIR/bin/genexis"
chmod +x "$BASE_DIR/modules"/*/run.sh

# Create symlink instead of copying (better)
echo "[+] Linking to /usr/local/bin..."

sudo ln -sf "$BASE_DIR/bin/genexis" /usr/local/bin/genexis

# Verify installation
if command -v genexis >/dev/null 2>&1; then
  echo "[✔] Installation successful!"
  echo ""
  echo "You can now run:"
  echo "   genexis --help"
else
  echo "[✖] Installation failed"
  exit 1
fi

echo "================================="
