#!/bin/bash
PROJECT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
export PROJECT_DIR
export SRC=/workspace/quard-star-upstream
export TOOLS=/workspace/riscv-env/root
export OUT="$PROJECT_DIR/output"
export JOBS=${JOBS:-4}
source /workspace/riscv-env/activate.sh
export PATH="/workspace/riscv-env/bin:$TOOLS/usr/bin:$TOOLS/usr/sbin:$PATH"
export LD_LIBRARY_PATH="$TOOLS/usr/lib/x86_64-linux-gnu${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
export PYTHONPATH="$TOOLS/usr/lib/python3/dist-packages${PYTHONPATH:+:$PYTHONPATH}"
export BISON_PKGDATADIR="$TOOLS/usr/share/bison"
export M4="$TOOLS/usr/bin/m4"
export PKG_CONFIG_PATH="$TOOLS/usr/lib/x86_64-linux-gnu/pkgconfig:$TOOLS/usr/share/pkgconfig"
export PKG_CONFIG_SYSROOT_DIR="$TOOLS"
export HOSTCFLAGS="-I$TOOLS/usr/include"
export HOSTLDFLAGS="-L$TOOLS/usr/lib/x86_64-linux-gnu"
mkdir -p "$OUT/logs" "$OUT/images" "$OUT/build"
