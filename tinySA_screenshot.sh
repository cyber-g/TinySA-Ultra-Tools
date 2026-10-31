#!/usr/bin/env bash
# TinySA Ultra Tools
# Project: https://github.com/cyber-g/TinySA-Ultra-Tools
# Author: https://github.com/cyber-g
# Description: Capture the tinySA Ultra display over the USB serial console.

set -euo pipefail

port="${1:-/dev/ttyACM0}"
image="${2:-screenshot.ppm}"
image_png="${image%.ppm}.png"
raw="$(mktemp)"
trap 'rm -f "$raw"' EXIT

stty -F "$port" 115200 raw -echo -ixon -ixoff -crtscts
exec 3<>"$port"

attendre_prompt() {
    local texte="" caractere
    while [[ "$texte" != *"ch> " ]]; do
        IFS= read -r -N 1 -t 20 caractere <&3 || {
            echo "Erreur : aucune reponse complete du tinySA." >&2
            return 1
        }
        texte+="$caractere"
    done
}

printf '\r' >&3
attendre_prompt
printf 'refresh off\r' >&3
attendre_prompt

printf 'capture\r' >&3
IFS= read -r -t 20 retour <&3
[[ "$retour" == $'capture\r' ]] || {
    echo "Erreur : reponse inattendue : $retour" >&2
    exit 1
}

timeout 20 dd bs=307200 count=1 iflag=fullblock status=none <&3 >"$raw"
[[ "$(stat -c %s "$raw")" == 307200 ]] || {
    echo "Erreur : capture incomplete." >&2
    exit 1
}
attendre_prompt

perl -0777 -ne '
    print "P6\n480 320\n255\n";
    for $p (unpack("n*", $_)) {
        print pack("C3",
            int((($p >> 11) & 31) * 255 / 31),
            int((($p >> 5) & 63) * 255 / 63),
            int(($p & 31) * 255 / 31));
    }
' "$raw" >"$image"

convert "$image" "$image_png"

echo "Capture enregistree : $image et $image_png"

