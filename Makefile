SHELL := /bin/bash

TOOLCHAIN_DIR = ./toolchain
TESTCASE_DIR = ./testcase
BUILD_DIR = ./build
SOFT_IP_CORE = ./riscv64i-softIPcore

# Tool Chain
CCG ?= $(TOOLCHAIN_DIR)/gnalc
ASM ?= $(TOOLCHAIN_DIR)/riscv-as
LINKER = $(TOOLCHAIN_DIR)/linker
QEMU ?= qemu-riscv64-static

# Share Lib
SYLIB = ./lib/sylib_standalone.o
# SYLIB = ./lib/sylib.o

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
	@printf "\033[32m>>> Testing Compiling $(TC)...\033[0m\n"
	@$(CCG) -S $(TESTCASE_SRC) -O1 -march=riscv64 --log none -o $(ASM_FILE)
	@printf "\033[33m<<< Has Built $(ASM_FILE)\n\033[0m\n"
$(OBJ_FILE): $(ASM_FILE)
	@printf "\033[32m>>> Testing Assemble $(TC)...\033[0m\n"
	@$(ASM) -c $(ASM_FILE) -o $(OBJ_FILE)
	@printf "\033[33m<<< Has Built $(OBJ_FILE)\n\033[0m\n"
$(ELF_FILE): $(OBJ_FILE)
	@printf "\033[32m>>> Testing Linking $(TC)...\033[0m\n"
	@$(LINKER) $(OBJ_FILE) $(SYLIB) -o $(ELF_FILE)
	@printf "\033[33m<<< Has Built $(ELF_FILE)\n\033[0m\n"
$(QEMU_RUN): $(ELF_FILE)
	@printf "\033[32m>>> Emulator Running...\033[0m\n"
	-@$(QEMU) $(ELF_FILE) < $(TESTCASE_IN) > $(RESULT_OUT); \
		DiffResult=$$?; \
		if [ -s "$(RESULT_OUT)" ] && [ "$$(tail -c 1 $(RESULT_OUT))" != "$$(printf '\n')" ]; then \
			printf "\n$$DiffResult\n" >> "$(RESULT_OUT)"; \
		else \
			printf "$$DiffResult\n" >> "$(RESULT_OUT)"; \
		fi

	@printf "\033[33m<<< Record $(RESULT_OUT)\n\033[0m\n"
	
	@printf "\033[32m>>> Result Diffing...\033[0m\n"
	-@diff $(RESULT_OUT) $(TESTCASE_OUT); \
		if [ $$? -eq 0 ]; then \
			printf "\033[34m<<< Testcase $(TC) PASSED\n\033[0m\n"; \
		else \
			printf "\033[31m<<< Testcase $(TC) FAILED\n\033[0m\n"; \
		fi
$(QEMU_DEBUG): $(ELF_FILE)
	@printf "\033[33m<<< Debuging $(TC)...\033[0m\n"
	@if [ $(GDB_PORT) -eq 1234 ]; then \
		printf "\033[34m=== Prot Open On $(GDB_PORT), change GDB_PORT to specific others\033[0m\n"; \
	 else \
		printf "\033[34m=== Prot Open On $(GDB_PORT)\033[0m\n"; \
	 fi
	@printf "\033[31m=== Hint: open gdb or lldb and type 'target remote localhost:1234'"
	@$(QEMU) -g $(GDB_PORT) $(ELF_FILE) < $(TESTCASE_IN)
	@printf "\033[32m>>> Prot Closed\033[0m\n"
$(NVBOARD_TEST):
	@printf "\033[33m<<< Virtual FPGA Board Running...\033[0m\n"
	@$(MAKE) -s -C $(SOFT_IP_CORE) ARCH=riscv64-npc ALL=$(TC) nvrun
	@printf "\033[32m>>> Virtual FPGA Board Closed\033[0m\n"
$(CLI_TEST):
	@printf "\033[33m<<< CLI DebugMode Running...\033[0m\n"
	@$(MAKE) -s -C $(SOFT_IP_CORE) ARCH=riscv64-npc ALL=$(TC) debug
	@printf "\033[32m>>> CLI DebugMode End\033[0m\n"

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