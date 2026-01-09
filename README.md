# Brief
这是电子科技大学信息与软件工程学院卓中卓方向第五学期综合设计成果汇报的测试和展示仓库
# ToolChain
- `gnalc`: 能进行高度优化的编译器，本次将主要展示`riscv64-gc`后端
- `riscv-as`: 可配置可拓展的汇编器，现已支持`riscv64-gc`所有指令
- `riscv64i`: 软核CPU，支持`riscv64-i`裸机程序运行
# Runtime
- `qemu-riscv64-static`: Linux用户态`riscv`模拟器
- `verilator`: `SystemVerilog`仿真工具，搭配其他GUI工具
- `DE2-115`: 用于实机测试的`FPGA`开发板
# Files And Dirs
- lib/sylib.o: SysY 的依赖库文件
- RISCV64i-softIPcore: 指向`riscv64i`工程文件夹的软链接文件夹
- testcase: 基本测试集
- toolchain: 存放编译器，汇编器和链接器
# Makefile Args
- `CCG`: 指定编译器
- `ASM`: 指定汇编器
- `LINKER`: 指定链接器
- `TC`: 指定测例
- `QEMU`: 指定模拟器
- `GDB_PORT`: 指定调试时的`gdbserver`开放端口
# Makefile Cmd
- `compile`: 仅测试编译器
- `assemble`: 测试编译器和汇编器
- `link`: 测试编译器、汇编器和链接器
- `run`: 通过模拟器测试工具链正确性
- `debug`: 通过模拟器和调试器对ELF进行调试
- `sim`: 进行带有GUI的`SystemVerilog`仿真
- `sim-debug`: 进行CLI下的`SystemVerilog`单步调试
# Dependencies And SoftWare
请参见 [gnalc](https://github.com/0x676e616c63/gnalc) 和 [riscv64i](https://github.com/Leakbox258/riscv64i)
# Warning
- `ToolChain` 和 `RISCV64i-softIPcore` 中的内容均为作者本地构建完成，可能会对复现造成一定困难
- 为了避免对系统本身动态库的依赖，打包了依赖库，同时对工具链的依赖路径进行修改
- 接上，由于依赖路径被修改为相对路径，故对`ToolChain`的调用必须在该项目的顶级路径下进行
- 由于综合和烧写工具闭源，开发板上的测试难以集成至测试脚本中，需要手动进行相关工作。