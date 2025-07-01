//! Core memory operations

/// Copy memory from source to destination
/// 
/// # Safety
/// - `dest` must be valid for writes of `n` bytes
/// - `src` must be value for reads of `n` bytes
/// - The memory regions must not overlap (use memmove for ovelapping regions)
#[no_mangle]
pub unsafe extern "C" fn memcpy(dest: *mut u8, src: *const u8, n: usize) -> *mut u8 {
    for i in 0..n {
        *dest.add(i) = *src.add(i);
    }
    dest
}

/// Set memory to a specific byte value
/// 
/// # Safety
/// - `s` must be valid for writes of `n` bytes
#[no_mangle]
pub unsafe extern "C" fn memset(s: *mut u8, c: i32, n: usize) -> *mut u8 {
    let byte_value = c as u8;
    for i in 0..n {
        *s.add(i) = byte_value;
    }
    s
}

/// Compare two memory regions
/// 
/// Returns:
/// - 0 if the regions are equal
/// - < 0 if the first differing byte in s1 is less than in s2
/// - > 0 if the first differing byte in s1 is greater than in s2
/// 
/// # Safety
/// - `s1` must be valid for reads of `n` bytes
/// - `s2` must be valid for reads of `n` bytes
#[no_mangle]
pub unsafe extern "C" fn memcmp(s1: *const u8, s2: *const u8, n: usize) -> i32 {
    for i in 0..n {
        let a = *s1.add(i);
        let b = *s2.add(i);
        if a != b {
            return (a as i32) - (b as i32);
        }
    }
    0
}

/// Move memory from source to destination (handles overlapping regions)
/// 
/// # Safety
/// - `dest` must be valid for writes of `n` bytes
/// - `src` must be valud for reads of `n` bytes
#[no_mangle]
pub unsafe extern "C" fn memmove(dest: *mut u8, src: *const u8, n: usize) -> *mut u8 {
    if dest < src as *mut u8 {
        // Copy forward (same as memcpy when no overlap)
        for i in 0..n {
            *dest.add(i) = *src.add(i);
        }
    } else {
        // Copy backward to handle overlap
        for i in (0..n).rev() {
            *dest.add(i) = *src.add(i);
        }
    }
    dest
}

// Rust-friendly wrapper functions for internal kernel use
impl crate::KernelMemory {
    /// Safe wrapper for memory copying (Rust-style)
    pub fn copy_memory(dest: &mut [u8], src: &[u8]) -> Result<(), &'static str> {
        if dest.len() != src.len() {
            return Err("Source and destination slices must have the same length");
        }
        
        unsafe {
            memcpy(dest.as_mut_ptr(), src.as_ptr(), src.len());
        }
        Ok(())
    }
    
    /// Safe wrapper for memory setting (Rust-style)
    pub fn set_memory(dest: &mut [u8], value: u8) {
        unsafe {
            memset(dest.as_mut_ptr(), value as i32, dest.len());
        }
    }
    
    /// Safe wrapper for memory comparison (Rust-style)
    pub fn compare_memory(a: &[u8], b: &[u8]) -> Option<core::cmp::Ordering> {
        if a.len() != b.len() {
            return None;
        }
        
        let result = unsafe {
            memcmp(a.as_ptr(), b.as_ptr(), a.len())
        };
        
        Some(match result {
            0 => core::cmp::Ordering::Equal,
            x if x < 0 => core::cmp::Ordering::Less,
            _ => core::cmp::Ordering::Greater,
        })
    }
}