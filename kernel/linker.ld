/* Simplified linker script for QEMU -kernel loading with multiboot support */
ENTRY(_start)

SECTIONS
{
	/* QEMU loads kernels at 1M by default */
	. = 1M;

	/* Multiboot header must be very early in the file */
	.text ALIGN(4K) : {
		*(.multiboot)
		*(.text)
	}

	/* Read-only data */
	.rodata ALIGN(4K) : {
		*(.rodata)
	}

	/* Read-write data (initialized) */
	.data ALIGN(4K) : {
		*(.data)
	}

	/* Read-write data (uninitialized) and stack */
	.bss ALIGN(4K) : {
		*(COMMON)
		*(.bss)
	}
}