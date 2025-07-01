#include "video.h"

enum video_type {
    VIDEO_TYPE_NONE = 0x00,
    VIDEO_TYPE_COLOR = 0x20,
    VIDEO_TYPE_MONOCHROME = 0x30,
};

uint16_t detect_bios_area_hardware(void) {
    const uint16_t* bda_detected_hardware_ptr = (const uint16_t*) 0x410;
    return *bda_detected_hardware_ptr;
}

enum video_type get_bios_area_video_type(void) {
    return (enum video_type) (detect_bios_area_hardware() & 0x30);
}

void write_string( int color, const char *string ) {
    if ( 0x0 > color > 0xF) {
        color = 0xF;
    }
    volatile char *video = (volatile char*)0xB8000;
    while ( *string != 0 ) {
        *video++ = *string++;
        *video++ = color;
    }
}

void init(void) {
    return;
}
