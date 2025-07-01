#include "video.h"

uint16_t detect_bios_area_hardware(void) {
    const uint16_t* bda_detected_hardware_ptr = (const uint16_t*) 0x410;
    return *bda_detected_hardware_ptr;
}

enum video_type get_bios_area_video_type(void) {
    return (enum video_type) (detect_bios_area_hardware() & 0x30);
}

void write_string(uint8_t color, const char *string ) {
    if ( color < 0x0 || color > 0xf) {
        color = 0xf;
    }
    // VGA text mode starts at 0xb8000
    volatile unsigned char *video = (volatile unsigned char*)0xb8000;
    while ( *string != 0 ) {
        *video++ = *string++;
        *video++ = color;
        if (video >= (volatile unsigned char*)0xb8fa0) break;
    }
}

void init(void) {
    return;
}
