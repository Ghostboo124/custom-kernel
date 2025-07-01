.PHONY: all clean rust-lib

# Detect operating system
ifeq ($(OS),Windows_NT)
#	Windows
	RM = del /Q /F
	NULL_DEVICE = nul
else
#	Unix-like (Linux, macOS, etc.)
	RM = rm -rf
	NULL_DEVICE = /dev/null
endif

# Project settings
# Compiler settings
ARCH		:= x86_64-elf
CC			:= $(ARCH)-gcc
LD			:= $(ARCH)-ld
OBJCOPY		:= $(ARCH)-objcopy

# Rust configuration
RUST_TARGET 		:= ./target.json
RUST_LIB			:= ../target/target/debug/libcustom_kernel.a
RUST_LIB_RELEASE	:= ../target/target/release/libcustom_kernel.a

# Include directories
KERNEL_INCLUDE_DIRS		:= $(shell find . -type d)
KERNEL_INCLUDE_FLAGS	:= $(addprefix -I, $(SHARED_INCLUDE_DIRS))

SHARED_INCLUDE_DIRS 	:= $(shell find ../shared -type d)
SHARED_INCLUDE_FLAGS 	:= $(addprefix -I, $(SHARED_INCLUDE_DIRS))

CFLAGS 		:= -g -O0 -ffreestanding -fno-exceptions -fno-unwind-tables -fno-asynchronous-unwind-tables -mcmodel=kernel -mno-mmx -mno-sse -mno-sse2 $(KERNEL_INCLUDE_FLAGS) $(SHARED_INCLUDE_FLAGS) -nostdlib -nostdinc -fno-builtin -fno-stack-protector -nostartfiles -nodefaultlibs -Wall -Wextra -c -mcmodel=large -mno-red-zone
LDFLAGS		:= -T linker.ld

C_SRC		:= $(shell find . -name '*.c')
ASM_SRC		:= $(shell find . -name '*.S') # For this, we will use GNU assembly because it can be compiled to .o files which are easier to deal with
CPP_SRC		:= $(shell find . -name '*.cpp')
RUST_SRC	:= $(shell find . -name '*.rs') # TODO: Rust will be implimented later (maybe)
OBJ			:= $(C_SRC:.c=.o) $(CPP_SRC:.cpp=.o) $(ASM_SRC:.S=.o)
OBJL		:= $(filter-out ./boot.o, $(OBJ))

ELF		:= kernel.elf
TARGET	:= kernel.bin

# Default target
all: $(TARGET)

# Build the kernel executable
$(TARGET): ../shared/libshared.a $(OBJ) rust-lib
	mkdir -p ../out/kernel/
	$(LD) $(LDFLAGS) -o ../out/kernel/$(ELF) $(OBJ) ../shared/libshared.a $(RUST_LIB)
	$(OBJCOPY) -O binary ../out/kernel/$(ELF) ../out/kernel/$(TARGET)

%.o: %.S
	$(CC) $(CFLAGS) -c $< -o $@

%.o: %.c
	$(CC) $(CFLAGS) -std=c23 -c $< -o $@

%.o: %.cpp
	$(CC) $(CFLAGS) -std=c++23 -fno-rtti -c $< -o $@

rust-lib:
	@echo "Building rust kernel library"
	cargo build --target $(RUST_TARGET)
	@echo "Rust library built"

# rust-release:
# 	@echo "Building optimized Rust kernel library..."
# 	@rustup target list --installed | grep -q $(RUST_TARGET) || rustup target add $(RUST_TARGET)
# 	cargo build --target $(RUST_TARGET) --release
# 	@echo "Optimized Rust library built successfully"

# Clean build artifacts
clean:
ifeq ($(OS),Windows_NT)
	@if exist "$(shell find . -name '*.o')" $(RM) "$(shell find . -name '*.o')" || echo.
	@if exist "..\out\kernel\$(ELF)" $(RM) "..\out\kernel\$(TARGET)" 2>$(NULL_DEVICE) || echo.
	@if exist "..\out\kernel\$(TARGET)" $(RM) "..\out\kernel\$(TARGET)" 2>$(NULL_DEVICE) || echo.
	cargo clean || echo.
else
	$(RM) $(shell find . -name '*.o') ../out/kernel/$(ELF) ../out/kernel/$(TARGET) || true
	cargo clean || true
endif
