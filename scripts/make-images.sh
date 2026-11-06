#!/bin/bash
set -euo pipefail
source "$(dirname "$0")/env.sh"
variant=${1:-custom}
case "$variant" in
 custom) bootcmd="$PROJECT_DIR/configs/boot.cmd" ;;
 baseline) bootcmd="$PROJECT_DIR/configs/boot.baseline.cmd" ;;
 *) echo 'usage: make-images.sh [custom|baseline]' >&2; exit 2 ;;
esac
riscv64-linux-gnu-gcc -Wall -Wextra -Werror -O2 -g "$PROJECT_DIR/app/bsp_demo.c" -o "$OUT/bsp_demo"
mkdir -p "$OUT/rootfs"/{etc/init.d,dev,proc,sys,tmp,run,mnt,var/log,usr/bin,lib,root}
cp -a "$PROJECT_DIR/rootfs/." "$OUT/rootfs/"
install -m755 "$OUT/bsp_demo" "$OUT/rootfs/usr/bin/bsp_demo"
for lib in ld-linux-riscv64-lp64d.so.1 libc.so.6 libm.so.6 libresolv.so.2; do
 install -m755 "$TOOLS/usr/riscv64-linux-gnu/lib/$lib" "$OUT/rootfs/lib/$lib"
done
find "$OUT/rootfs" -type d -exec chmod 755 {} +
chmod 755 "$OUT/rootfs/etc/init.d/rcS"
chmod 644 "$OUT/rootfs/etc/inittab" "$OUT/rootfs/etc/profile" "$OUT/rootfs/etc/passwd" "$OUT/rootfs/etc/group"
"$OUT/build/uboot/tools/mkimage" -A riscv -O linux -T script -C none -a 0 -e 0 -n 'Quard Star BSP boot' -d "$bootcmd" "$OUT/images/boot.scr"
truncate -s 96M "$OUT/images/bootfs.fat"
mkfs.fat -F32 -n BOOT "$OUT/images/bootfs.fat"
mcopy -o -i "$OUT/images/bootfs.fat" "$OUT/images/Image" ::/Image
mcopy -o -i "$OUT/images/bootfs.fat" "$OUT/images/quard_star_uboot.dtb" ::/quard_star.dtb
mcopy -o -i "$OUT/images/bootfs.fat" "$OUT/images/boot.scr" ::/boot.scr
truncate -s 256M "$OUT/images/rootfs.ext4"
mke2fs -q -t ext4 -b 4096 -O ^orphan_file -L rootfs -E root_owner=0:0 -d "$OUT/rootfs" -F "$OUT/images/rootfs.ext4"
python3 "$PROJECT_DIR/scripts/pack-images.py"
printf '%s\n' "$variant" > "$OUT/images/variant.txt"
