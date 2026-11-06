#!/bin/bash
set -euo pipefail
source "$(dirname "$0")/env.sh"
make -C "$SRC/u-boot-2023.04" O="$OUT/build/uboot" CROSS_COMPILE=riscv64-linux-gnu- qemu-quard-star_defconfig
mkdir -p "$OUT/build/uboot/drivers/video"
cp "$SRC/u-boot-2023.04/drivers/video/u_boot_logo.bmp" "$OUT/build/uboot/drivers/video/"
make -C "$SRC/u-boot-2023.04" O="$OUT/build/uboot" CROSS_COMPILE=riscv64-linux-gnu- olddefconfig
make -C "$SRC/u-boot-2023.04" O="$OUT/build/uboot" CROSS_COMPILE=riscv64-linux-gnu- \
 HOSTCFLAGS="-O2 -I$TOOLS/usr/include" HOSTLDFLAGS="-L$TOOLS/usr/lib/x86_64-linux-gnu" \
 -j"$JOBS" EXT_DTB="$OUT/images/quard_star_uboot.dtb"
cp "$OUT/build/uboot/u-boot.bin" "$OUT/images/"
cp "$OUT/build/uboot/.config" "$OUT/images/uboot.config"
