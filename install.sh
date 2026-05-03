#!/bin/bash

echo "================================="
echo " Installing Genexis Toolkit 🧬"
echo "================================="

# Get project root directory
BASE_DIR="$(cd "$(dirname "$0")" && pwd)"

# Ensure we target the file named 'genexis' (no extension)
TARGET_BIN="$BASE_DIR/bin/genexis"

if [[ ! -f "$TARGET_BIN" ]]; then
  echo "Error: $TARGET_BIN not found"
  exit 1
fi

# Make scripts executable
echo "[+] Setting permissions..."
chmod +x "$TARGET_BIN"
chmod +x "$BASE_DIR/modules"/*/run.sh

# Create wrapper script in /usr/local/bin
# This wrapper explicitly points to the full path of your script
echo "[+] Creating wrapper script in /usr/local/bin..."
echo '#!/bin/bash' | sudo tee /usr/local/bin/genexis > /dev/null
echo "bash \"$TARGET_BIN\" \"\$@\"" | sudo tee -a /usr/local/bin/genexis > /dev/null
sudo chmod +x /usr/local/bin/genexis
