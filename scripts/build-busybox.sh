#!/bin/bash
set -euo pipefail
source "$(dirname "$0")/env.sh"
mkdir -p "$OUT/build/busybox"
make -C "$SRC/busybox-1.33.2" O="$OUT/build/busybox" ARCH=riscv CROSS_COMPILE=riscv64-linux-gnu- quard_star_defconfig
sed -i 's/^CONFIG_TC=y/# CONFIG_TC is not set/' "$OUT/build/busybox/.config"
make -C "$SRC/busybox-1.33.2" O="$OUT/build/busybox" ARCH=riscv CROSS_COMPILE=riscv64-linux-gnu- oldconfig </dev/null
make -C "$SRC/busybox-1.33.2" O="$OUT/build/busybox" ARCH=riscv CROSS_COMPILE=riscv64-linux-gnu- -j"$JOBS"
make -C "$SRC/busybox-1.33.2" O="$OUT/build/busybox" ARCH=riscv CROSS_COMPILE=riscv64-linux-gnu- CONFIG_PREFIX="$OUT/rootfs" install
