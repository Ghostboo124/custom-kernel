all: boot.bin

boot.bin:
	mkdir -p ../out/bootloader/
	nasm -f bin boot.asm -o ../out/bootloader/boot.bin
# 	dd if=../out/bootloader/boot.bin of=../kernel.img bs=512 count=1 conv=notrunc

# boot.bin: boot.o
# 	x86_64-elf-gcc -m16 -nostdlib -nostartfiles -nodefaultlibs -Wl,--oformat=binary -Wl,-Ttext=0x7c00 -o ../bin/boot.bin boot.o

# boot.o: boot.S
# 	x86_64-elf-gcc -c boot.S -o boot.o

clean:
	rm -rf ../out/bootloader