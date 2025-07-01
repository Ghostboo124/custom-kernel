.code32
.global _start
_start:
    # Set up basic segments
    mov $0x10, %ax
    mov %ax, %ds
    mov %ax, %es
    mov %ax, %fs
    mov %ax, %gs
    mov %ax, %ss
    mov $0x90000, %esp
    
    # Call kernel main
    call kernel_main
    
    # Halt
    cli
    hlt

# Basic GDT for QEMU
.align 8
gdt:
    .quad 0x0000000000000000  # Null descriptor
    .quad 0x00CF9A000000FFFF  # Code segment
    .quad 0x00CF92000000FFFF  # Data segment
gdt_end:

gdt_desc:
    .word gdt_end - gdt - 1
    .long gdt