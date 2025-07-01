.PHONY: all clean boot kernel

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
CC			:= gcc -m32
AR			:= ar
OBJCOPY		:= objcopy

CFLAGS		:= -g -O0 -ffreestanding -fno-exceptions -fno-unwind-tables -fno-asynchronous-unwind-tables -mno-mmx -mno-sse -mno-sse2 -I. -I../kernel -nostdlib -nostdinc -fno-builtin -fno-stack-protector -nostartfiles -nodefaultlibs -Wall -Wextra -c

C_SRC		:= $(shell find . -name '*.c')
ASM_SRC		:= $(shell find . -name '*.S') # For this, we will use GNU assembly because it can be compiled to .o files which are easier to deal with
CPP_SRC		:= $(shell find . -name '*.cpp')
RUST_SRC	:= $(shell find . -name '*.rs') # TODO: Rust will be implimented later (maybe)
OBJ			:= $(C_SRC:.c=.o) $(CPP_SRC:.cpp=.o) $(ASM_SRC:.S=.o)

TARGET		:= libshared.a

all: $(TARGET)

$(TARGET): $(OBJ)
	$(AR) rcs $(TARGET) $(OBJ)

%.o: %.S
	$(CC) $(CFLAGS) -c $< -o $@

%.o: %.c
	$(CC) $(CFLAGS) -std=c11 -c $< -o $@

%.o: %.cpp
	$(CC) $(CFLAGS) -std=c++11 -fno-rtti -c $< -o $@

# Clean build artifacts
clean:
ifeq ($(OS),Windows_NT)
	@if exist "$(shell find . -name '*.o')" $(RM) "$(shell find . -name '*.o')" || echo.
	@if exist "..\out\kernel\$(ELF)" $(RM) "..\out\kernel\$(TARGET)" 2>$(NULL_DEVICE) || echo.
	@if exist "..\out\kernel\$(TARGET)" $(RM) "..\out\kernel\$(TARGET)" 2>$(NULL_DEVICE) || echo.
else
	$(RM) $(shell find . -name '*.o') || true
endif
