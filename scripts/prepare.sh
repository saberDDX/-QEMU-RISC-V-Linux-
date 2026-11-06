#!/bin/bash
# Debian 13 cloud host; no root or system package installation required.
set -euo pipefail
project=$(cd "$(dirname "$0")/.." && pwd)
base=/workspace/riscv-env
cache=/workspace/scratch
mkdir -p "$cache" "$base/apt"/{lists/partial,archives/partial,empty} "$base/root"
# Reuse the onboarding's tested relocated Linux compiler wrappers.
if [ ! -x "$base/install.sh" ]; then
 echo 'Missing /workspace/riscv-env/install.sh; restore the prepared cloud environment first.' >&2
 exit 1
fi
"$base/install.sh"
export APT_CONFIG="$base/apt/apt.conf"
/usr/bin/apt-get --download-only --no-install-recommends -y install \
 ninja-build meson libglib2.0-dev libpixman-1-dev libfdt-dev \
 e2fsprogs dosfstools mtools fdisk python3-dev python3-pyelftools swig \
 uuid-dev libncurses-dev autoconf automake libtool
# dev-package symlinks must resolve locally even when base-image runtime packages exist.
(cd "$cache" && /usr/bin/apt-get download libglib2.0-0t64 libpixman-1-0 && mv libglib2.0-0t64_*.deb libpixman-1-0_*.deb "$base/apt/archives/")
for package in "$base"/apt/archives/*.deb; do dpkg-deb -x "$package" "$base/root"; done
fetch() {
 local url=$1 dest=$2 sum=$3
 if [ -f "$dest" ] && echo "$sum  $dest" | sha256sum -c --status; then return; fi
 curl -fLsS --connect-timeout 20 --max-time 600 "$url" -o "$dest.part"
 echo "$sum  $dest.part" | sha256sum -c
 mv "$dest.part" "$dest"
}
commit=083d2dd8337adc0c7fd0522e1d16e075b9f11365
fetch "https://codeload.github.com/QQxiaoming/quard_star_tutorial/tar.gz/$commit" "$cache/quard-pinned.tar.gz" 747e698f0762a968e2acae6bb70b7f9a02e34aa0cde460b89072c3e5bc285a9e
fetch https://github.com/riscv-collab/riscv-gnu-toolchain/releases/download/2021.08.07/riscv64-elf-ubuntu-20.04-nightly-2021.08.07-nightly.tar.gz "$cache/riscv-newlib.tar.gz" b4e8bf5bc41eaac8c786734ad5dfb062fe789fb4b40bfd0c315e8d87edb45c00
fetch https://codeload.github.com/mirror/newlib-cygwin/tar.gz/refs/tags/newlib-4.1.0 "$cache/newlib-source.tar.gz" 19bef2689e9ec48354f4a218ba4e1ac6c2531ae1243b9862b325516bbd2731e0
extract_once() {
 local archive=$1 dest=$2
 if [ -f "$dest/.quard-bsp-extracted" ]; then return; fi
 if [ -e "$dest" ]; then echo "Refusing to overwrite unmarked directory $dest" >&2; exit 1; fi
 mkdir -p "$dest"
 tar -xzf "$archive" -C "$dest" --strip-components=1
 touch "$dest/.quard-bsp-extracted"
}
fetch https://github.com/riscv-collab/riscv-gnu-toolchain/releases/download/2021.08.07/riscv64-glibc-ubuntu-20.04-nightly-2021.08.07-nightly.tar.gz "$cache/riscv-linux-gcc11.tar.gz" 80b18185765b0d1c97122dca6accec0fc9cc0429120c474c0b653d1c5304c0ac
extract_once "$cache/riscv-linux-gcc11.tar.gz" "$base/linux-gcc11"
extract_once "$cache/quard-pinned.tar.gz" /workspace/quard-star-upstream
extract_once "$cache/riscv-newlib.tar.gz" "$base/newlib"
extract_once "$cache/newlib-source.tar.gz" "$base/newlib-source"
printf '%s\n' "$commit" > /workspace/quard-star-upstream/.upstream-commit
printf 'Preparation complete. Run %s/scripts/build-all.sh\n' "$project"
