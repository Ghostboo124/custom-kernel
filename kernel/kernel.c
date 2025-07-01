/*
Copyright (C) Alexander Perkins, 2025
This work is free. You can redistribute it and/or modify it under the
terms of the Do What The Fuck You Want To But It's Not My Fault Public
License, Version 1, as published by Ben McGinnes. See the
COPYING.WTFNMFPLv1a.txt file for more details.
*/

#include <types.h>

// Rust functions
extern void init_rkernel(void);

// Temporary stub for testing - writes directly to VGA memory
void init_rkernel(void) {
    // Simple VGA text output to 0xB8000 
    volatile char* video = (volatile char*)0xB8000;
    const char* msg1 = "Rust Video System Initialized";
    const char* msg2 = "Kernel is running!";
    
    // Clear screen
    for (int i = 0; i < 80 * 25 * 2; i += 2) {
        video[i] = ' ';
        video[i + 1] = 0x07;  // White on black
    }
    
    // Write first message
    int pos = 0;
    while (msg1[pos] != '\0') {
        video[pos * 2] = msg1[pos];
        video[pos * 2 + 1] = 0x0A;  // Light green on black
        pos++;
    }
    
    // Move to next line (80 chars * 2 bytes per char)
    pos = 80;
    int msg2_pos = 0;
    while (msg2[msg2_pos] != '\0') {
        video[pos * 2] = msg2[msg2_pos];
        video[pos * 2 + 1] = 0x0F;  // White on black
        pos++;
        msg2_pos++;
    }
}

// Video memory for text mode
volatile char* video_memory = (volatile char*)0xB8000;

void kernel_main() {
    // Initialize Rust video system first (this will clear screen and set up video)
    init_rkernel();
    
    // Infinite loop to prevent kernel from returning
    while (1) {
        asm volatile("hlt"); // Halt until interrupt
    }
}