#!/bin/bash
set -euo pipefail
source "$(dirname "$0")/env.sh"
# QEMU gdbstub, not KGDB. Bind only to the host loopback interface.
exec "$PROJECT_DIR/scripts/run.sh" -S -gdb tcp:127.0.0.1:1234 "$@"
