#!/bin/bash
set -euo pipefail
source "$(dirname "$0")/env.sh"
export PATH="/workspace/riscv-env/newlib/bin:$PATH"
mkdir -p "$OUT/build/newlib"
cd "$OUT/build/newlib"
if [ ! -f Makefile ]; then
 /workspace/riscv-env/newlib-source/configure --target=riscv64-unknown-elf \
 --prefix=/workspace/riscv-env/newlib-medany --disable-multilib --disable-nls \
 --disable-newlib-supplied-syscalls --enable-newlib-io-long-long \
 CFLAGS_FOR_TARGET='-O2 -mcmodel=medany -march=rv64imafdc -mabi=lp64d'
fi
make -j"$JOBS" all-target-newlib
make install-target-newlib
