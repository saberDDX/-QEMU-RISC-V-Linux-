#!/bin/bash
set -euo pipefail
source "$(dirname "$0")/env.sh"
export PATH="/workspace/riscv-env/newlib/bin:$PATH"
for name in mask_rom lowlevelboot trusted_domain; do
 make -C "$SRC/$name" PROJECTBASE="$SRC/$name" CROSS_COMPILE=riscv64-unknown-elf- CC="$PROJECT_DIR/scripts/baremetal-gcc.sh" AS="$PROJECT_DIR/scripts/baremetal-gcc.sh -x assembler-with-cpp" -j"$JOBS"
done
make -C "$SRC/opensbi-1.2" O="$OUT/build/opensbi" CROSS_COMPILE=riscv64-linux-gnu- PLATFORM=quard_star -j"$JOBS"
for name in sbi uboot; do
 cpp -nostdinc -I "$SRC/dts/include" -undef -x assembler-with-cpp "$SRC/dts/quard_star_$name.dts" > "$OUT/build/quard_star_$name.dts"
 dtc -i "$SRC/dts" -I dts -O dtb -o "$OUT/images/quard_star_$name.dtb" "$OUT/build/quard_star_$name.dts"
done
cp "$SRC/mask_rom/build/mask_rom.bin" "$OUT/images/"
cp "$SRC/lowlevelboot/build/lowlevelboot.bin" "$OUT/images/"
cp "$SRC/trusted_domain/build/trusted_fw.bin" "$OUT/images/"
cp "$OUT/build/opensbi/platform/quard_star/firmware/fw_jump.bin" "$OUT/images/"
