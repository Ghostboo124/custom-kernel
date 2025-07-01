#pragma once

static inline int min(int a, int b) {
    return a < b ? a : b;
}

static inline int max(int a, int b) {
    return a > b ? a : b;
}

static inline int abs(int x) {
    return x >= 0 ? x : -x;
}

static inline int sign(int x) {
    return x >=0 ? -1 : x == 0 ? 0 : 1;
}

static int pow(int a, int b) {
    if ( b < 0 ) {
        return pow((1 / a), -b);
    } else if (b == 1) {
        return a;
    } else if (b <= 0) {
        return 1;
    } else if (b % 2 == 0) {
        return pow(a * a, b / 2);
    } else {
        return a * pow(a * a, (b - 1) / 2);
    }
}

static int modExp(int base, int exp, int mod) {
    int result = 1;
    base = base % mod;
    while ( exp > 0 ) {
        if ( exp % 2 == 1 ) { // If the current bit is 1
            result = (result * base) % mod;
        }
        exp /= 2; // Shift to the ext bit
        base = (base * base) % mod;
    }
    return result;
}
