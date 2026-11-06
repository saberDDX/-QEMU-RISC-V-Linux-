#!/usr/bin/env python3
"""Pack regular files only; never opens a host block device or uses mount."""
import os
import shutil
import struct
from pathlib import Path

images = Path(os.environ['OUT']) / 'images'
size = 32 * 1024 * 1024
fw = images / 'firmware.img'
layout = [('lowlevelboot.bin', 0, 512 * 1024),
          ('quard_star_sbi.dtb', 512 * 1024, 512 * 1024),
          ('quard_star_uboot.dtb', 1024 * 1024, 1024 * 1024),
          ('fw_jump.bin', 2 * 1024 * 1024, 2 * 1024 * 1024),
          ('trusted_fw.bin', 4 * 1024 * 1024, 4 * 1024 * 1024),
          ('u-boot.bin', 8 * 1024 * 1024, 4 * 1024 * 1024)]
with fw.open('wb') as f:
    f.write(b'\xff' * size)
    for name, offset, limit in layout:
        data = (images / name).read_bytes()
        if len(data) > limit:
            raise ValueError(f'{name} exceeds reserved slot')
        f.seek(offset)
        f.write(data)
for target in ['pflash.img', 'norflash.img', 'sd.img']:
    shutil.copyfile(fw, images / target)

parts = [(0x80, 0x0c, 2048, 196608, 'bootfs.fat'),
         (0, 0x83, 198656, 524288, 'rootfs.ext4')]
mbr = bytearray(512)
for index, (boot, kind, start, count, name) in enumerate(parts):
    if (images / name).stat().st_size != count * 512:
        raise ValueError('partition image size mismatch')
    struct.pack_into('<B3sB3sII', mbr, 446 + 16 * index,
                     boot, b'\xfe\xff\xff', kind, b'\xfe\xff\xff', start, count)
mbr[510:512] = b'\x55\xaa'
with (images / 'disk.img').open('wb') as disk:
    disk.truncate((198656 + 524288) * 512)
    disk.write(mbr)
    for _, _, start, _, name in parts:
        disk.seek(start * 512)
        with (images / name).open('rb') as src:
            shutil.copyfileobj(src, disk)
print('Packed firmware images and 353 MiB MBR disk: FAT32 boot + ext4 rootfs')
