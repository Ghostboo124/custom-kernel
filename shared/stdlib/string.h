#pragma once

#include "types.h"

typedef struct {
    char *data;
    size_t length;
    size_t mem_length;
} string;

typedef struct string_list {
    size_t count;
    char array[];
} string_list;

string string_l(const char *literal);
string string_ca_max(const char *array, size_t max_length);
string string_c(const char c);

// Standard C library functions needed by Rust
void* memcpy(void* dest, const void* src, size_t n);
void* memset(void* s, int c, size_t n);
int memcmp(const void* s1, const void* s2, size_t n);
