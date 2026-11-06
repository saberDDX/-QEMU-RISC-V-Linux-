#!/bin/bash
exec /workspace/riscv-env/newlib/bin/riscv64-unknown-elf-gcc \
 -isystem /workspace/riscv-env/newlib-medany/riscv64-unknown-elf/include \
 -L/workspace/riscv-env/newlib-medany/riscv64-unknown-elf/lib "$@"
