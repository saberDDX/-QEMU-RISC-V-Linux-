#!/bin/bash
set -euo pipefail
source "$(dirname "$0")/env.sh"
mkdir -p "$OUT/build/qemu"
cd "$OUT/build/qemu"
if [ ! -f build.ninja ]; then
 "$SRC/qemu-8.0.0/configure" --prefix="$OUT/qemu" \
   --target-list=riscv64-softmmu \
   --meson="$TOOLS/usr/bin/meson" --ninja="$TOOLS/usr/bin/ninja" \
   --with-git-submodules=ignore --disable-werror --disable-docs \
   --disable-gtk --disable-sdl --disable-opengl --disable-virglrenderer \
   --disable-vnc --disable-gio --disable-tools --disable-user \
   --disable-capstone --enable-fdt=system --audio-drv-list= \
   --extra-cflags="-I$TOOLS/usr/include" \
   --extra-ldflags="-L$TOOLS/usr/lib/x86_64-linux-gnu"
fi
ninja -j"$JOBS" qemu-system-riscv64
./qemu-system-riscv64 -machine help | grep quard-star
