.PHONY: all kernel.img kernel shared bootloader clean run debug 
all: kernel.img kernel bootloader
	@echo "Build complete!"

kernel.img:
# 	32 MiB + MBR
	qemu-img create kernel.img 34078720

kernel: kernel.img shared
	@echo "Building kernel"
	$(MAKE) -C kernel
	@echo "Finished building kernel"

shared:
	@echo "Building shared libraries"
	$(MAKE) -C shared
	@echo "Finished building shared libraries"

bootloader: kernel.img
	@echo "Building bootloader"
	$(MAKE) -C bootloader
	@echo "Finished building bootloader"

clean:
	$(MAKE) -C kernel clean
	$(MAKE) -C shared clean
	$(MAKE) -C bootloader clean

run: all
	qemu-system-x86_64 -kernel out/kernel/kernel.bin -vga cirrus

debug: all
	@echo "UNFINISHED"
