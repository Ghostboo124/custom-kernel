#include "string.h"

void* memcpy(void* dest, const void* src, size_t n) {
    char *d = (char*)dest;
    const char *s = (const char*)src;
    
    while (n--) {
        *d++ = *s++;
    }
    
    return dest;
}

void* memset(void* s, int c, size_t n) {
    unsigned char *p = (unsigned char*)s;
    
    while (n--) {
        *p++ = (unsigned char)c;
    }
    
    return s;
}

int memcmp(const void* s1, const void* s2, size_t n) {
    const unsigned char *p1 = (const unsigned char*)s1;
    const unsigned char *p2 = (const unsigned char*)s2;
    
    while (n--) {
        if (*p1 != *p2) {
            return *p1 - *p2;
        }
        p1++;
        p2++;
    }
    
    return 0;
}