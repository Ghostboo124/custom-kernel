#![no_std]              // Disable the standard library
#![no_main]             // Disable rust's standard main function
#![feature(asm_const)]  // Enable inline assembly

use core::panic::PanicInfo;

mod video; // Include the video module

#[panic_handler]
fn panic(_info: &PanicInfo) -> ! {
    // For now just halt the system
    // TODO: Impliment writing error message to the screen or serial console, or QEMU debug console
    unsafe {
        asm!("cli");
        loop {
            asm!("hlt");
        }
    }
}

#[no_mangle]
pub extern "C" fn init_rkernel() {
    video::init_video
}