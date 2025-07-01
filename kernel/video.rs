// Video library in rust

use core::ptr;

const VGA_WIDTH: usize = 80;
const VGA_HEIGHT: usize = 25;
const VGA_MEMORY: *mut u16 = 0xB8000 as *mut u16;

// Color enumeration
#[derive(Copy, Clone)]
#[repr(u8)] // Ensures the values of the enum are u8s
pub enum Color {
    Black = 0,
    Blue = 1,
    Green = 2,
    Cyan = 3,
    Red = 4,
    Purple = 5,
    Brown = 6,
    Gray = 7,
    DarkGray = 8,
    LightBlue = 9,
    LightGreen = 10,
    LightCyan = 11,
    LightRed = 12,
    LightPurple = 13,
    Yellow = 14,
    White = 15,
}

// Struct for managing sreen state
pub struct VgaWriter {
    column_position: usize,
    row_position: usize,
    color_code: u8,
}

impl VgaWriter {
    pub fn new() -> VgaWriter {
        VgaWriter {
            column_position: 0,
            row_position: 0,
            color_code: Self::color_code(Color::Yellow, Color::Black),
        }
    }

    //! Helper function to combine Foreground and Background colors
    fn color_code(foreground: Color, background: Color) {
        (background as u8) << 4 | (foreground as u8)
    }

    //! Safe wrapper around VGA memory access
    fn write_char(&mut self, character: u8, color: u8, col: usize, row: usize) {
        let offset = row * VGA_WIDTH + col;
        let char_with_color = (color as u16) << 8 | character as u16;

        unsafe { // The 'unsafe' block marks that we are doing low-level memory operations
            ptr::write_volatile(VGA_MEMORY.add(offset), char_with_color);
        }
    }

    pub fn write_string(&mut self, s: &str) {
        for byte in s.bytes() {
            match byte {
                // Handle printable ASCII chars
                0x20..=0x7e => {
                    if self.column_position >= VGA_WIDTH {
                        self.new_line();
                    }
                    self.write_char(byte, self.color_code, self.column_position, self.row_position);
                    self.column_position += 1;
                }
            }
        }
    }

    fn new_line(&mut self) {
        self.row_position += 1;   // Increment the row and...
        self.column_position = 0; // reset the column

        if self.row_position >= VGA_HEIGHT {
            self.scroll_up();
            self.row_position = VGA_HEIGHT - 1;
        }
    }

    fn scroll_up(&mut self) {
        unsafe {
            // Copy each line up one position
            for row in 1..VGA_HEIGHT {
                for col in 0..VGA_HEIGHT {
                    let src_offset = row * VGA_WIDTH + col;
                    let dst_offset = (row - 1) * VGA_WIDTH + col;
                    let character = ptr::read_volatile(VGA_MEMORY.add(src_offset));
                    ptr::write_volatile(VGA_MEMORY.add(dst_offset), character)
                }
            }

            // Clear the last line
            for col in 0..VGA_WIDTH {
                let offset = (VGA_HEIGHT - 1) * VGA_WIDTH + col;
                let blank = (self.color_code as u16) << 8 | b' ' as u16;
                ptr::write_volatile(VGA_MEMORY.add(offset), blank);
            }
        }
    }

    pub fn clear_screen(&mut self) {
        let blank = (self.color_code as u16) << 8 | b' ' as u16;
        unsafe {
            for i in 0..(VGA_WIDTH * VGA_HEIGHT) {
                ptr::write_volatile(VGA_MEMORY.add(i), blank);
            }
        }
        self.column_position = 0; // Reset the column and...
        self.row_position = 0;    // row
    }

    pub fn set_color(&mut self, foreground: Color, background: Color) {
        self.color_code = Self::color_code(foreground, background);
    }
}

// Global writer instance, for interfacing with C
static mut WRITER: VgaWriter = VgaWriter {
    column_position: 0,
    row_position: 0,
    color_code: 15, // White on black
};

// Write String function to be called from C
#[no_mangle]
pub extern "C" fn print(s: *const u8, len: usize) {
    if s.is_null() {
        return;
    }

    unsafe {
        // Convert C to Rust slice
        let slice = core::slice::from_raw_parts(s, len);
        if let Ok(string) = core::string::from_utf8(slice) {
            WRITER.write_string(string);
        }
    }
}

pub fn init_video() {
    unsafe {
        WRITER.clear_screen();
        WRITER.set_color(Color::LightGreen, Color::Black);
        WRITER.write_string("Rust Video System Initialized\n");
    }
}