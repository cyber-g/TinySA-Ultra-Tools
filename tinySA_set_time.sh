#!/usr/bin/env bash
# TinySA Ultra Tools
# Project: https://github.com/cyber-g/TinySA-Ultra-Tools
# Author: https://github.com/cyber-g
# Description: Set the tinySA Ultra clock from the host system time over USB serial.

set -euo pipefail

port="${1:-/dev/ttyACM0}"
stty -F "$port" 115200 raw -echo -ixon -ixoff -crtscts
exec 3<>"$port"
printf 'time b %s\r' "$(date '+0x%y%m%d 0x%H%M%S')" >&3
exec 3>&-

