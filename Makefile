TOOLCHAIN_DIR = ./toolchain
TESTCASE_DIR = ./testcase
BUILD_DIR = ./build
SOFT_IP_CORE = ./RISCV64i-softIPcore

# Tool Chain
CC ?= $(TOOLCHAIN_DIR)/gnalc
ASM ?= $(TOOLCHAIN_DIR)/riscv-as
# LINKER = $(TOOLCHAIN_DIR)/linker
LINKER ?= /usr/bin/riscv64-linux-gnu-gcc
QEMU ?= qemu-riscv64-static

# Share Lib
SYLIB = ./lib/sylib.o

# Single Testcase
TC ?= dummy
TESTCASE = $(if $(filter %.sy,$(TC)),$(TC),$(TC).sy)
TESTCASE_SRC = $(TESTCASE_DIR)/$(TESTCASE)
TESTCASE_IN = $(TESTCASE_DIR)/$(subst .sy,,$(TESTCASE)).in
TESTCASE_OUT = $(TESTCASE_DIR)/$(subst .sy,,$(TESTCASE)).out
RESULT_OUT = $(BUILD_DIR)/$(subst .sy,,$(TESTCASE)).out

# Intermediate Build Result
ASM_FILE = $(BUILD_DIR)/$(subst .sy,,$(TC)).s
OBJ_FILE = $(BUILD_DIR)/$(subst .sy,,$(TC)).o
ELF_FILE = $(BUILD_DIR)/$(subst .sy,,$(TC))
QEMU_RUN = qemu_run
QEMU_DEBUG = qemu_debug
GDB_PORT ?= 1234
$(BUILD_DIR):
	@mkdir -p ./build

# On Board Test
NVBOARD_TEST = nvboard_test
CLI_TEST = cli_test

$(ASM_FILE): $(BUILD_DIR)
	@echo -e "\033[32m>>> Testing Compiling $(TC)...\033[0m"
	@$(CC) -S $(TESTCASE_SRC) -O1 -march=riscv64 --log none -o $(ASM_FILE)
	@echo -e "\033[33m<<< Has Built $(ASM_FILE)\n\033[0m"
$(OBJ_FILE): $(ASM_FILE)
	@echo -e "\033[32m>>> Testing Assemble $(TC)...\033[0m"
	@$(ASM) -c $(ASM_FILE) -o $(OBJ_FILE)
	@echo -e "\033[33m<<< Has Built $(OBJ_FILE)\n\033[0m"
$(ELF_FILE): $(OBJ_FILE)
	@echo -e "\033[32m>>> Testing Linking $(TC)...\033[0m"
	@$(LINKER) $(OBJ_FILE) $(SYLIB) -o $(ELF_FILE)
	@echo -e "\033[33m<<< Has Built $(ELF_FILE)\n\033[0m"
$(QEMU_RUN): $(ELF_FILE)
	@echo -e "\033[32m>>> Emulator Running...\033[0m"
	-@$(QEMU) $(ELF_FILE) < $(TESTCASE_IN) > $(RESULT_OUT); \
		DiffResult=$$?; \
		if [ -s "$(RESULT_OUT)" ] && [ "$$(tail -c 1 $(RESULT_OUT))" != "$$(printf '\n')" ]; then \
			echo -e "\n$$DiffResult" >> "$(RESULT_OUT)"; \
		else \
			echo -e "$$DiffResult" >> "$(RESULT_OUT)"; \
		fi

	@echo -e "\033[33m<<< Record $(RESULT_OUT)\n\033[0m"
	
	@echo -e "\033[32m>>> Result Diffing...\033[0m"
	-@diff $(RESULT_OUT) $(TESTCASE_OUT); \
		if [ $$? -eq 0 ]; then \
			echo -e "\033[34m<<< Testcase `$(TC)` PASSED\n\033[0m"; \
		else \
			echo -e "\033[31m<<< Testcase `$(TC)` FAILED\n\033[0m"; \
		fi
$(QEMU_DEBUG): $(ELF_FILE)
	@echo -e "\033[33m<<< Debuging $(TC)...\033[0m"
	@if [ $(GDB_PORT) -eq 1234 ]; then \
		echo -e "\033[34m=== Prot Open On $(GDB_PORT), change GDB_PORT to specific others\033[0m"; \
	 else \
		echo -e "\033[34m=== Prot Open On $(GDB_PORT)\033[0m"; \
	 fi
	@echo -e "\033[31m=== Hint: open gdb or lldb and type 'target remote localhost:1234'"
	@$(QEMU) -g $(GDB_PORT) $(ELF_FILE) < $(TESTCASE_IN)
	@echo -e "\033[32m>>> Prot Closed\033[0m"
$(NVBOARD_TEST):
	@echo -e "\033[33m<<< Virtual FPGA Board Running...\033[0m"
	@$(MAKE) -s -C $(SOFT_IP_CORE) ARCH=riscv64-npc ALL=$(TC) nvrun
	@echo -e "\033[32m>>> Virtual FPGA Board Closed\033[0m"
$(CLI_TEST):
	@echo -e "\033[33m<<< CLI DebugMode Running...\033[0m"
	@$(MAKE) -s -C $(SOFT_IP_CORE) ARCH=riscv64-npc ALL=$(TC) debug
	@echo -e "\033[32m>>> CLI DebugMode End\033[0m"

# Test Compiling Toolchain With Emulator
compile: $(ASM_FILE)
assemble: $(OBJ_FILE)
link: $(ELF_FILE)
run: $(QEMU_RUN)
debug: $(QEMU_DEBUG)

# Test Compiling Toolchain With Verilator (Simulate)
sim: $(NVBOARD_TEST)
sim-debug: $(CLI_TEST)

clean:
	@rm -f $(BUILD_DIR)/*