#!/bin/bash
set -euo pipefail
source "$(dirname "$0")/env.sh"
exec "$OUT/build/qemu/qemu-system-riscv64" \
 -M "quard-star,mask-rom-path=$OUT/images/mask_rom.bin,canbus=canbus0" \
 -m 1G -smp 8 -accel tcg \
 -global quard-star-syscon.boot-cfg=sd \
 -global quard-star-syscon.update-cfg=false \
 -drive "if=pflash,bus=0,unit=0,format=raw,file=$OUT/images/pflash.img" \
 -drive "if=mtd,bus=0,unit=0,format=raw,file=$OUT/images/norflash.img" \
 -drive "if=sd,format=raw,file=$OUT/images/sd.img" \
 -drive "if=none,format=raw,file=$OUT/images/disk.img,id=disk0" \
 -object can-bus,id=canbus0 -audiodev none,id=audio0 \
 -fw_cfg 'name=opt/qemu_cmdline,string=qemu_vc=:vn:24x80:' \
 -global virtio-mmio.force-legacy=false -device virtio-blk-device,drive=disk0,id=hd0 \
 -nic none -display none -monitor none -parallel none \
 -serial stdio -serial "file:$OUT/logs/uart1.log" -serial "file:$OUT/logs/trusted-domain.log" "$@"
