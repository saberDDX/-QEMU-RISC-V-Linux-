#!/bin/bash
set -euo pipefail
source "$(dirname "$0")/env.sh"
exec gdb-multiarch -nx -q "$OUT/build/linux/vmlinux" \
 -ex 'set pagination off' \
 -iex 'set auto-load off' \
 -ex 'target remote 127.0.0.1:1234' "$@"
