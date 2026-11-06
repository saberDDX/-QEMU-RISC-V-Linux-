# 扩展：QEMU gdbstub 内核启动调试

依据官方 `tutorial/ext4.md`，只补充启动调试，不重复编写设备树/字符设备示例。本实验在已有 Quard Star 整机上完成，不是仅对离线 ELF 做反汇编。

## 与第一个项目的区别

RK3576 项目重点是外设驱动及采集。本扩展重点是“系统还没进入 Shell 时，如何停住、找源码位置和查看状态”。可迁移的是调试思路；真实板卡使用 KGDB、JTAG 或其他硬件接口时，连接方式和条件不同，不能据此宣称已经完成真实板卡 KGDB/JTAG 调试。

## 两个终端复现

先确认普通 QEMU 已关机，一份磁盘只运行一个实例。

终端 A（宿主）：

```bash
cd /workspace/-QEMU-RISC-V-Linux-
./scripts/run-debug.sh
```

它在原启动命令上增加 `-S -gdb tcp:127.0.0.1:1234`。`-S` 是暂停 vCPU 等待调试；GDB 监听仅在宿主回环地址，不是 SSH，也不是客户机内运行的 gdbserver。此时没有启动日志是预期状态。

终端 B（宿主）：

```bash
cd /workspace/-QEMU-RISC-V-Linux-
./scripts/debug-kernel.sh
```

连接后依次输入，不要一次把后面的步骤在未停住时全部输入：

```gdb
hbreak start_kernel
continue
```

等固件、OpenSBI 和 U-Boot 完成，停在内核入口后：

```gdb
info registers pc sp
bt
list 937,953
next
print init_task.comm
hbreak run_init_process
continue
```

第二次停住后：

```gdb
print init_filename
bt
info registers pc sp a0
list 1423,1435
delete breakpoints
# 提示确认时输入 y
detach
quit
```

然后回终端 A，看到 bsp_demo 自启动后按回车进入 Shell，检查 `uname -r`、`cat /proc/cmdline`、`/usr/bin/bsp_demo manual`，最后 `sync`、`poweroff`。

源码行号和地址只对应当前固定版本；其他版本应按函数名和实际源码重新查看。首次断点与 MMU 切换有关，使用 hbreak 避免提前修改尚未加载或映射的内核代码。本文未改动内核配置，也未为了调试取消现有内存保护配置。

## 本次实际结果

现有内核已经启用 DEBUG_INFO、DWARF4、GDB_SCRIPTS 和 FRAME_POINTER，直接复用匹配的 vmlinux，无需重编。

- 硬件断点 1：`start_kernel`，PC=`0xffffffff808bc058`，源码 `init/main.c:937`。
- `bt` 显示 `start_kernel → _start_kernel`；`next` 到 941 行；`print init_task.comm` 为 `swapper`。
- 硬件断点 2：`run_init_process`，源码 `init/main.c:1427`。
- 参数 `init_filename` 为 `/sbin/init`。
- 调用栈显示 `run_init_process → try_to_run_init_process → kernel_init → handle_exception`。
- 删除断点后 detach，虚拟系统继续运行并进入 Shell；程序自启动和手动运行通过。

完整记录：`evidence/gdb-startup.log`、`evidence/boot-after-gdb.log`。地址是实测记录，不是后续版本的固定常量。

## 面试只需掌握这六点

1. **Image 与 vmlinux**：Image 用于引导；vmlinux 是带符号和调试信息的 ELF，供 GDB 找函数、源码和变量，必须与运行内核匹配。
2. **gdbstub 与 KGDB**：前者在 QEMU 中控制虚拟 CPU；后者是内核侧调试机制。客户机尚未运行 Linux 时，QEMU stub 仍能接入。本次只验证前者。
3. **-S 与 -gdb / -s**：-S 暂停 vCPU；-gdb 配置调试接口；-s 是默认 TCP 1234 监听的简写。本工程明确绑定 127.0.0.1。
4. **断点与阶段**：start_kernel 证明进入内核 C 启动流程；run_init_process 的参数证明内核准备执行哪个 init。本例是 `/sbin/init`，之后 BusyBox 再按 inittab 调用 rcS。
5. **基本命令**：hbreak 断点；continue 运行；next 源码单步越过调用；bt 调用栈；print 变量；info registers 寄存器；list 源码；detach 断开并让 QEMU 继续执行。
6. **边界**：本次验证的是停点、单步、状态检查和启动交接，没有新造内核故障，也没有声称找到并修复了某个真实驱动 bug。汇编入口的栈回溯停止不自动等于栈损坏；优化后的变量显示 optimized out 也不等于程序故障。

## 简历可增加一句

“使用 QEMU gdbstub 与 GDB 对 RISC-V Linux 启动流程进行源码级断点调试，查看寄存器、调用栈及 init 路径，验证内核入口到用户空间启动的交接。”

保留原来的“基于开源 Quard Star 构建与定制”定位，不写成从零 BSP 移植，也不写成已具备真实板卡 KGDB/JTAG 调试经验。
