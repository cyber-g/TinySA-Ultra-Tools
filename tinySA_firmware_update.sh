#!/usr/bin/env bash
# TinySA Ultra Tools
# Project: https://github.com/cyber-g/TinySA-Ultra-Tools
# Author: https://github.com/cyber-g
# Description: Update a tinySA Ultra firmware using dfu-util over USB DFU mode.
# Usage: ./tinySA_firmware_update.sh tinySA4_vX.X-XXX.bin
# Firmware list: https://dfu.tinydevices.org/tinySA4/DFU/

set -euo pipefail

BASE_URL="https://dfu.tinydevices.org/tinySA4/DFU/"
FW="${1:?Usage : $0 <fichier.bin> (voir $BASE_URL)}"

command -v dfu-util >/dev/null || { echo "dfu-util manquant (sudo apt install dfu-util)"; exit 1; }

# Téléchargement
wget -q --show-progress -O "$FW" "$BASE_URL$FW"

# Attente du mode DFU
echo "Éteindre le tinySA Ultra, maintenir le bouton jog enfoncé, allumer (écran noir), brancher l'USB."
until dfu-util -l 2>/dev/null | grep -q "0483:df11"; do sleep 1; done
echo "Appareil DFU détecté."

# Flash
out=$(dfu-util -d 0483:df11 -a 0 -s 0x08000000:leave -D "$FW" 2>&1) || true
echo "$out"
grep -q "File downloaded successfully" <<< "$out" || { echo "Échec du flash, recommencer."; exit 1; }

echo "Terminé. Éteindre puis rallumer le tinySA, puis faire CONFIG > MORE > CLEAR CONFIG 1234 et un selftest."


