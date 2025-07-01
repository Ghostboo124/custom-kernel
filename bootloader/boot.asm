; Copyright (C) Alexander Perkins, 2025

; This work is free.  You can redistribute it and/or modify it under the
; terms of the Do What The Fuck You Want To But It's Not My Fault Public
; License, Version 1, as published by Ben McGinnes.  See the
; COPYING.WTFNMFPLv1a.txt file for more details.

bits 16				; We are in 16bit "Real" mode
org 0x0600    ; Tell assembler that this program will be loaded at 0x6000 in memory (after being copied over)

%define setCursorPos  0x02
%define scrollUp      0x06
%define writeChar     0x0e
%define videoInt      0x10

start:
  cli             ; Clear and disable interrupts
  mov ax, 0x00    ; Set ax to 0
  mov ds, ax      ; Set Data Segment to 0
  mov es, ax      ; Set Extra Segment to 0
  mov ss, ax      ; Set Stack Segment to 0
  mov sp, ax      ; Set Stack Pointer to 0
  .CopyLower:
    mov cx, 0x0100  ; 256 WORDs in MBR
    mov si, 0x7C00  ; Current MBR Address
    mov di, 0x0600  ; New MBR Address
    rep movsw       ; Copy MBR
  jmp 0:LowStart

LowStart:
  sti                         ; Re-enable BIOS interrupts
  mov byte [bootDrive], dl    ; Save the boot drive
  .CheckPartitions:           ; Check the partition table for a bootable partition
    mov bx, PT1               ; Base = Partition Table Entry 1
    mov cx, 4                 ; There are 4 Partition Table Entries
    .CKPTloop:
      mov al, byte [bx]       ; Get Boot indicator bit flag
      test al, 0x80           ; Check for Active Bit
      jnz .CKPTFound          ; We found an Active Partition
      add bx, 0x10            ; Partition Table Entry is 16 bytes
      dec cx                  ; Decrement Counter
      jnz .CKPTloop           ; Loop
    jmp error
    .CKPTFound:
      mov WORD [PToff], bx    ; Save offset
      add bx, 8               ; Increment Base to LBA Address
  .ReadVBR:
    mov ebx, dword [bx]       ; Start LBA of Active Partition
    mov di, 0x7c00            ; We are loading VBR to 0x07C0:0x0000
    mov cx, 1                 ; Only 1 sector
    call ReadSectors          ; Read Sector
  
  .jumpToVBR:
    cmp word [0x7dfe], 0xaa55 ; Check Boot Signiture
    jne error
    mov si, word [PToff]      ; Set DS:SI to Partition Table Entry
    mov dl, byte [bootDrive]  ; Set DL to Drive Number
    jmp 0x7c00                ; Jump to VBR

	jmp end

ReadSectors:
; NOTE: Kernel should be loaded at 0x10000 physical (es=0x1000,bx=0 when using int 0x13)
  jmp end

error:
	mov ah, setCursorPos
	mov dh, 0
	mov dl, 0
	mov bh, 0
	int videoInt
	ret

	mov ah, scrollUp
	xor al, al
	xor cx, cx
	mov dx, 0x184f
	mov bh, 0x1f		; Blue background, white foreground
	int videoInt

	mov ah, writeChar
	mov bh, 0
	mov cx, 1
	mov si, errorMsg	; Move into register si, the error message

  errorLoop:
	lodsb			; Mov one byte into register sb and increment counter
	test al, al		; Check if al is 0 (NULL char) meaning end of string
	jz errorEnd
	int videoInt
	jmp errorLoop
	
  errorEnd:
	jmp end

end:
  cli
  hlt

times 218 - ($ - $$) nop      ; Pad for disk time stamp

DiskTimeStamp times 8 db 0    ; Disk Time Stamp

bootDrive db 0x00             ; Drive Number
PToff dw 0                    ; Partition Table Entry Offset

errorMsg db "Error Has Occured!", 0

times 436 - ($ - $$) nop            ; Pad for MBR Partition Table

UID times 10 db 0             ; Unique Disk ID

;; Each Partition Table Entry should be 16 bytes long
; Offset | Size (bytes) | Description
;  0x00  |      1       | Drive attributes (bit 7 set = active or bootable)
;  0x01  |      3       | Cylinder, Head, Sector (CHS) Address of partition start
;  0x04  |      1       | Partition Type
;  0x05  |      3       | CHS Address of last partition sector
;  0x08  |      4       | Logical Block Address (LBA) of partition start
;  0x0C  |      4       | Number of sectors in partition
; CHS can be converted to LBA by doing: LBA = (C * HPC + H) * SPT + (S - 1)
; Where C, H, and S are the cylinder number, the head number, and sector number
; LBA is the logical block address
; HPC is the macimum number of heads per cylinder (reported by disk drive, typically 16)
; SPT is the maximum number of sectors per track (reported by disk drive, typically 63)

PT1:
; First partition table entry
db 0b10000000			; Drive attributes (bit 7 set (0x80) = active or bootable)

db 0b00000000			; Head of partition start (0)
db 0b00000000			; Sector of partition start (1) + Cylinder High bits (0)
db 0b00000001			; Cylinder low bits of partition start (0)

db 0x07			    	; Partition Type (HPFS/NTFS/exFAT) 0b00000111

db 0b00000000			; Head of last partition sector (0)
db 0b00100000			; Sector (32) + Cylinder High Bits (0) of last partition sector
db 0b00011111			; Cylinder Low bits (31) of last partition sector

db 0b00000000			; First byte of LBA of partition start
db 0b00000000			; Second byte of LBA of partition start
db 0b00000000			; Third byte of LBA of partition start
db 0b00000000			; Fourth byte of LBA of partition start

db 0b00000000			; First byte of number of sectors in partition    (65'536)
db 0b00000000			; Second byte of number of sectors in partition
db 0b00000001			; Third byte of number of sectors in partition
db 0b00000000			; Fourth byte of number of sectors in partition

PT2 times 16 db 0             ; Second Partition Entry
PT3 times 16 db 0             ; Third Partition Entry
PT4 times 16 db 0             ; Fourth Partition Entry

; $ means start of file, $$ means the current position (I think)
; times 510 - ($ - $$) db 0

dw 0xaa55