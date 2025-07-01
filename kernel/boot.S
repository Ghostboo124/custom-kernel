# Copyright (C) Alexander Perkins, 2025
# This work is free. You can redistribute it and/or modify it under the
# terms of the Do What The Fuck You Want To But It's Not My Fault Public
# License, Version 1, as published by Ben McGinnes. See the
# COPYING.WTFNMFPLv1a.txt file for more details.

.code16                    # We are in 16bit "Real" mode
.global _start

_start:
    # Set up segments
    cli                    # Disable interrupts
    xor %ax, %ax          # Zero out AX
    mov %ax, %ds          # Set DS = 0
    mov %ax, %es          # Set ES = 0
    mov %ax, %ss          # Set SS = 0
    mov $0x7C00, %sp      # Set stack pointer
    sti                   # Re-enable interrupts

    # Load kernel from disk (simplified - load 1 sector after MBR)
    mov $0x02, %ah        # BIOS read sectors function
    mov $1, %al           # Number of sectors to read
    mov $0x00, %ch        # Cylinder 0
    mov $0x02, %cl        # Sector 2 (after MBR)
    mov $0x00, %dh        # Head 0
    mov $0x80, %dl        # Drive 0 (first hard drive)
    mov $0x1000, %bx      # Load kernel to 0x1000
    int $0x13             # Call BIOS
    jc disk_error         # Jump if carry flag set (error)

    # Switch to protected mode
    lgdt gdt_descriptor   # Load GDT
    
    mov %cr0, %eax        # Get CR0
    or $1, %eax           # Set PE bit
    mov %eax, %cr0        # Enable protected mode
    
    # Far jump to flush pipeline and switch to 32-bit code
    ljmp $0x08, $protected_mode

disk_error:
    # Print error message and halt
    mov $0x0E, %ah        # BIOS teletype output
    mov $'E', %al
    int $0x10
    hlt

.code32
protected_mode:
    # Set up 32-bit segments
    mov $0x10, %ax        # Data segment selector
    mov %ax, %ds
    mov %ax, %es
    mov %ax, %fs
    mov %ax, %gs
    mov %ax, %ss
    mov $0x90000, %esp    # Set up stack

    # Call kernel_main (now we can call C functions)
    call kernel_main
    
    # If kernel returns, halt
    cli
    hlt

# GDT (Global Descriptor Table)
gdt_start:
    # Null descriptor
    .quad 0x0000000000000000

    # Code segment descriptor
    .quad 0x00CF9A000000FFFF

    # Data segment descriptor  
    .quad 0x00CF92000000FFFF

gdt_end:

gdt_descriptor:
    .word gdt_end - gdt_start - 1    # GDT size
    .long gdt_start                   # GDT address

# Pad to 446 bytes (start of partition table)
.org 446
PT1: .space 16, 0         # First Partition Entry
PT2: .space 16, 0         # Second Partition Entry  
PT3: .space 16, 0         # Third Partition Entry
PT4: .space 16, 0         # Fourth Partition Entry

# Boot signature at offset 510
.org 510
.word 0xaa55