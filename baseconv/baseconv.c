#include <errno.h>
#include <limits.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int get_int(void) {
    int res = 0;
    while (scanf("%d", &res) == 0) {
        fprintf(stderr, "invalid input, try again\n> ");
        while (getchar() != '\n')
            continue;
    }
    getchar(); // consume newline
    return res;
}

char* ltostr(char* buf, size_t buf_len, long num, int base) {
    // num serves as the quotient
    const char CHARS[] =
        "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijlmnopqrstuvwxyz";
    long rem = 0;
    if (base > sizeof(CHARS))
        return NULL;

    size_t len = 0;
    for (; num != 0; num = (long)num / base) {
        rem = (long)num % base;
        if (len + 1 > buf_len)
            return NULL; // not enough space
        buf[len++] = CHARS[rem];
    }

    // padding
    if (base == 2 && len % 4 != 0) {
        // chunks of 4
        for (size_t i = 0; i < len % 4; ++i) {
            if (len + 1 > buf_len)
                return NULL;
            buf[len++] = '0';
        }
    }

    buf[len] = '\0';

    // reverse
    for (size_t i = 0; i < (size_t)len / 2; ++i) {
        char tmp = buf[i];
        buf[i] = buf[len - 1 - i];
        buf[len - 1 - i] = tmp;
    }

    return buf;
}

int main(void) {
    char buf[32] = {0};
    int base, target_base;

    printf("enter current base: ");
    base = get_int();

    printf("enter num: ");
    fgets(buf, sizeof(buf) - 1, stdin);
    char* endptr = NULL;

    printf("enter target base (default: 10): ");
    if (scanf("%d", &target_base) == 0) {
        while (getchar() != '\n')
            continue;
        target_base = 10;
    }

    errno = 0;
    long num = strtol(buf, &endptr, base);
    if (endptr == buf) {
        fprintf(stderr, "no valid number (from: %s)", endptr);
    } else if (errno == ERANGE && num == LONG_MIN) {
        fprintf(stderr, "number underflow");
    } else if (errno == ERANGE && num == LONG_MAX) {
        fprintf(stderr, "number overflow");
    } else {
        char resb[32] = {0};
        if (!ltostr(resb, sizeof(resb), num, target_base))
            fprintf(stderr, "error converting base");
        else
            printf("result: %s\n", resb);
    }
}
