#pragma once

#ifndef asm
#define asm __asm__ // Very important! Some compilers don't have the asm keyword builtin!
#endif

#ifdef __cplusplus
extern "C" {
#endif

typedef unsigned int uint32_t;
typedef long unsigned int size_t;
typedef unsigned long uint64_t;
typedef unsigned long uintptr_t;
typedef unsigned short uint16_t;
typedef unsigned char uint8_t;

typedef int int32_t;
typedef long int64_t;
typedef long intptr_t;
typedef short int16_t;
typedef char int8_t;

typedef struct sizedptr {
    uintptr_t ptr;
    size_t size;
} sizedptr;

#define NULL 0

#ifdef __cplusplus
}
#else

#define true 1
#define false 0

#endif
