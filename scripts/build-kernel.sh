#!/bin/bash
set -euo pipefail
source "$(dirname "$0")/env.sh"
make -C "$SRC/linux-6.1.11" O="$OUT/build/linux" ARCH=riscv CROSS_COMPILE=/workspace/riscv-env/linux-gcc11/bin/riscv64-unknown-linux-gnu- quard_star_defconfig
"$SRC/linux-6.1.11/scripts/config" --file "$OUT/build/linux/.config" --disable FTRACE --disable GCC_PLUGINS
make -C "$SRC/linux-6.1.11" O="$OUT/build/linux" ARCH=riscv CROSS_COMPILE=/workspace/riscv-env/linux-gcc11/bin/riscv64-unknown-linux-gnu- olddefconfig
make -C "$SRC/linux-6.1.11" O="$OUT/build/linux" ARCH=riscv CROSS_COMPILE=/workspace/riscv-env/linux-gcc11/bin/riscv64-unknown-linux-gnu- -j"$JOBS" Image
cp "$OUT/build/linux/arch/riscv/boot/Image" "$OUT/images/Image"
cp "$OUT/build/linux/.config" "$OUT/images/linux.config"
