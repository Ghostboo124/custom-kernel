.code32

# Multiboot constants
.set ALIGN,    1<<0
.set MEMINFO,  1<<1
.set FLAGS,    ALIGN | MEMINFO
.set MAGIC,    0x1BADB002
.set CHECKSUM, -(MAGIC + FLAGS)

# Multiboot header for QEMU/GRUB compatibility
.section .multiboot
.align 4
.long MAGIC
.long FLAGS  
.long CHECKSUM

.section .text
.global _start

# Basic GDT for kernel execution  
.align 8
gdt_start:
    .quad 0x0000000000000000  # Null descriptor
    .quad 0x00CF9A000000FFFF  # Code segment (base=0, limit=0xFFFFF, 32-bit, readable, executable)
    .quad 0x00CF92000000FFFF  # Data segment (base=0, limit=0xFFFFF, 32-bit, writable)
gdt_end:

gdt_descriptor:
    .word gdt_end - gdt_start - 1    # GDT size
    .long gdt_start                  # GDT address

_start:
    # Disable interrupts
    cli
    
    # Load our GDT
    lgdt gdt_descriptor
    
    # Set up segment registers with proper selectors
    mov $0x10, %ax    # Data segment selector (2nd entry in GDT)
    mov %ax, %ds      # Data segment
    mov %ax, %es      # Extra segment  
    mov %ax, %fs      # FS segment
    mov %ax, %gs      # GS segment
    mov %ax, %ss      # Stack segment
    
    # Set up stack at 1MB - 4KB (safe location below kernel)
    mov $0x100000, %esp
    sub $0x1000, %esp
    
    # Far jump to reload CS with code segment selector
    ljmp $0x08, $reload_cs
    
reload_cs:
    # Call kernel main
    call kernel_main
    
    # If kernel_main returns, halt the system
halt:
    cli
    hlt
    jmp halt