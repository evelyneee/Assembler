//
//  Use this file to import your target's public headers that you would like to expose to Swift.
//

#include <stdlib.h>
#include <mach/mach.h>
#include <stdio.h>

extern const void* assembly(const unsigned char code[], size_t);

void assembly2(void) {
    
    const unsigned char code[] = {
        0x20, 0x00, 0x80, 0xd2, // mov x0, #1
        0x30, 0x00, 0x80, 0xd2, // mov x16, #1
        0x01, 0x10, 0x00, 0xd4, // svc #0x80
        0xc0, 0x03, 0x5f, 0xd6 // ret
    };
    
    assembly(code, sizeof(code));
}

void hexDump(char *desc, void *addr, int len)
{
    int i;
    unsigned char buff[17];
    unsigned char *pc = (unsigned char*)addr;

    // Output description if given.
    if (desc != NULL)
        printf ("%s:\n", desc);

    // Process every byte in the data.
    for (i = 0; i < len; i++) {
        // Multiple of 16 means new line (with line offset).

        if ((i % 16) == 0) {
            // Just don't print ASCII for the zeroth line.
            if (i != 0)
                printf("  %s\n", buff);

            // Output the offset.
            printf("  %04x ", i);
        }

        // Now the hex code for the specific character.
        printf(" %02x", pc[i]);

        // And store a printable ASCII character for later.
        if ((pc[i] < 0x20) || (pc[i] > 0x7e)) {
            buff[i % 16] = '.';
        } else {
            buff[i % 16] = pc[i];
        }

        buff[(i % 16) + 1] = '\0';
    }

    // Pad out last line if not exactly 16 characters.
    while ((i % 16) != 0) {
        printf("   ");
        i++;
    }

    // And print the final ASCII bit.
    printf("  %s\n", buff);
}
