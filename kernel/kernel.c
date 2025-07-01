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

// Video memory for text mode
volatile char* video_memory = (volatile char*)0xB8000;

void kernel_main() {
    // Clear screen (first 80*25*2 bytes)
    for (int i = 0; i < 80 * 25 * 2; i += 2) {
        video_memory[i] = ' ';      // Character
        video_memory[i + 1] = 0x07; // Attribute (white on black)
    }
    
    // Print "Hello, Kernel!" message
    const char* message = "Hello, Kernel!";
    int pos = 0;
    
    while (message[pos] != '\0') {
        video_memory[pos * 2] = message[pos];      // Character
        video_memory[pos * 2 + 1] = 0x0F;         // Attribute (bright white on black)
        pos++;
    }

    init_rkernel();
    
    // Infinite loop to prevent kernel from returning
    while (1) {
        asm volatile("hlt"); // Halt until interrupt
    }
}