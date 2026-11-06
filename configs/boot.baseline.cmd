echo Quard Star BSP: loading kernel and device tree from virtio disk
load virtio 0:1 ${fdt_addr_r} /quard_star.dtb
load virtio 0:1 ${kernel_addr_r} /Image
setenv bootargs 'root=/dev/vda2 rw console=ttyS0 earlycon=sbi loglevel=7'
booti ${kernel_addr_r} - ${fdt_addr_r}
