/* RLM - Recover Lunar Magic
 *
 * Copyright notice for this file:
 *  Copyright (C) 2003-2009 Jason Oster
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 */


#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#include "_types.h"


#define VERSION "v1.4" /* RLM Version Number */


#define HDR_MAKEUP      0x00FFD5 /* ROM Header, ROM Makeup */
#define HDR_SIZE        0x00FFD7 /* ROM Header, ROM size */
#define HDR_CHECKSUM    0x00FFDC /* ROM Header, Checksum */
#define PTR_ROMHEADER   0x00FFBF /* ROM Header */

#define PTR_CRYPTFUNC   0x00B8DF /* Pointer to encrypted-pointer decryption routine */
#define PTR_CRYPTPTRS   0x00B992 /* Encrypted-pointers */
#define PTR_CRYPTUNK0   0x00B88B /* Unknown */
#define PTR_CRYPTUNK1   0x00B8D8 /* Unknown */
#define PTR_UNKNOWN     0x03BB1F /* Unknown */
#define PTR_OWPTR       0x04D801 /* OverWorld enhancement pointers */
#define PTR_STAGEPTRS   0x05E000 /* Pointers to stage data */
#define PTR_USTAGEPTRS  0x05E600 /* Pointers to unknown stage data */
#define PTR_STAGEFUNC   0x058606 /* Pointer to stage data decryption routine */

#define PTR_EXGFXPTRS   0x0FF600 /* ExGFX Pointers */
#define PTR_SEXGFXPTRS  0x0FF873 /* Super ExGFX Pointers ... not "SexGFX" ... ugh! */
#define PTR_OVERWORLD   0x04D807 /* Hard-coded OverWorld pointer */


u8 headdata[] = {
    0xFF, 0x53, 0x55, 0x50, 0x45, 0x52, 0x20, 0x4D,
    0x41, 0x52, 0x49, 0x4F, 0x57, 0x4F, 0x52, 0x4C,
    0x44, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x02,
    0x09, 0x01, 0x01, 0x01, 0x00
};

u8 orgcrypt[] = {
    0xC2, 0x10, 0xA0, 0x00, 0x00
};

u8 orgstage[] = {
    0x85, 0x0A, 0xC8, 0xB7, 0x65
};


u32 snesLoROM2File(u32 ptr, int header) {
    //if (ptr > 0x6FFFFF) ptr &= 0x3FFFFF; //cheap hack!
    return ((((ptr & 0x7F0000) >> 1) | (ptr & 0x7FFF)) + (header ? 0x0200 : 0));
}

u32 snesFile2LoROM(u32 ptr, int header) {
    return ((((ptr << 1) & 0x7F0000) | (ptr & 0x7FFF)) + (header ? 0x0200 : 0));
}


u32 snesExHiROM2File(u32 ptr, int header) {
    ptr &= 0xFFFFFF;
    if ((ptr >> 22) == 3) return ((ptr & 0x3FFFFF) + (header ? 0x200 : 0));
    return (((ptr & 0x3FFFFF) | 0x400000) + (header ? 0x0200 : 0));
}

u32 snesFile2ExHiROM(u32 ptr, int header) {
    ptr &= 0x7FFFFF;
    if (!(ptr >> 22)) return ((ptr | 0xC00000) + (header ? 0x0200 : 0));
    return (ptr + (header ? 0x0200 : 0));
}


u32 snesFile2ROM(u32 ptr, int type, int header) {
    switch (type) {
        case 0x00: return snesFile2LoROM(ptr, header);
        case 0x05: return snesFile2ExHiROM(ptr, header);
    }
    return 0;
}

u32 snesROM2File(u32 ptr, int type, int header) {
    switch (type) {
        case 0x00: return snesLoROM2File(ptr, header);
        case 0x05: return snesExHiROM2File(ptr, header);
    }
    return 0;
}


void snesGenChecksum(u8 *buffer, int size, int type, int header) {
    u32 ptr;
    u16 sum = 0, chk[16];
    int i;

    memset(chk, 0, 16 * sizeof(u16));

    // Clear old checksum
    ptr = snesROM2File(HDR_CHECKSUM, type, header);
    buffer[ptr + 0] = 0xFF;
    buffer[ptr + 1] = 0xFF;
    buffer[ptr + 2] = 0x00;
    buffer[ptr + 3] = 0x00;

    ptr = (header ? 0x0200 : 0);
    for (i = 0; i < (size << 17); i++) {
        chk[i >> 19] += buffer[ptr];
        ptr++;
    }
    if (size & 3) {
        // Uneven rom size
        printf("Warning: This ROM has an uneven size! Checksum generation failed.\n");
    }
    for (i = 0; i < 16; i++) {
        sum += chk[i];
    }

    //set new checksum
    ptr = snesROM2File(HDR_CHECKSUM,type,header);
    buffer[ptr + 0] = (~sum & 0xFF);
    buffer[ptr + 1] = (~sum >> 8);
    buffer[ptr + 2] = (sum & 0xFF);
    buffer[ptr + 3] = (sum >> 8);
}

void decryptLunar(u8 *buffer, u32 dst, u32 seeds) {
    u16 tmp;

    while (buffer[dst] != 0xFF) {
        buffer[dst + 0] ^= buffer[seeds + 7];
        buffer[dst + 1] ^= buffer[seeds + 18];
        tmp = 3;
        switch (((buffer[dst + 0] >> 1) & 0x30) | (buffer[dst + 1] >> 4)) {
            case 0x00:
                if (buffer[dst + 2] == 0x00) tmp = 4;
                break;
            case 0x22:
            case 0x23:
                tmp = 4;
                break;
            case 0x27:
                tmp = 5;
                break;
        }
        dst += tmp;
    }
}

int main(int argc, char **argv) {
    FILE *fin, *fout;
    u32 filesize, header, ptr, ptr2, dst;
    u32 ptrseeds, seeds;
    u16 tmp;
    u8 *buffer, minibuf[9];
    char *outname, *chr;
    int i, num, type = 0, namelen = 0;


    // Not Recover Lunar Magic! RAPE LUNAR MAGIC! HAH!
    printf("RLM (Recover Lunar Magic) - "VERSION"\nCopyright 2003-2009 Parasyte (parasyte@kodewerx.org)\nhttp://www.kodewerx.org/\n\n");

    if ((argc < 2) || (argc > 3)) {
        printf("Usage: %s <in-file.smc> [out-file.smc]\n\n", argv[0]);
        return 1;
    }

    // Implicit output file name
    if (argc < 3) {
        namelen = (strlen(argv[1]) + 13); // 13 bytes for ".unlocked.smc"
        if (!(outname = (char*)malloc(namelen))) {
            printf("Unable to allocate %d bytes of memory\n\n", namelen);
            return 1;
        }
        strcpy(outname, argv[1]);
        if ((chr = strrchr(outname, '.'))) {
            *chr = '\0';
        }
        strcat(outname, ".unlocked.smc");
    }
    else {
        outname = argv[2];
    }

    // Open input file
    if (!(fin = fopen(argv[1], "rb"))) {
        printf("Unable to open input file \"%s\"\n\n", argv[1]);
        if (namelen) free(outname);
        return 1;
    }

    // Read input file into memory
    fseek(fin, 0, SEEK_END);
    filesize = ftell(fin);
    header = (filesize & 0x7FFF);
    if ((header) && (header != 0x0200)) {
        printf("Error: SMC header appears to be invalid\n\n");
        if (namelen) free(outname);
        fclose(fin);
        return 1;
    }
    if (!(buffer = (u8*)malloc(filesize))) {
        printf("Unable to allocate %d bytes of memory\n\n", filesize);
        if (namelen) free(outname);
        fclose(fin);
        return 1;
    }
    fseek(fin, 0, SEEK_SET);
    fread(buffer, 1, filesize,fin);
    fclose(fin);


    // Verify ROM file
    for (type = 0; type < 0x10; type++) {
        ptr = snesROM2File(HDR_CHECKSUM, type, header);
        tmp = (((buffer[ptr + 1] ^ buffer[ptr + 3]) << 8) | (buffer[ptr + 0] ^ buffer[ptr + 2]));
        if ((tmp == 0xFFFF) && ((buffer[snesROM2File(HDR_MAKEUP, type, header)] & 0x0F) == type)) break;
    }
    if (type == 0x10) printf("SNES ROM mapping type: ??\n");
    else printf("SNES ROM mapping type: %d\n", type);

    if (type != 0) {
        printf("Error: Unsupported SNES ROM mapping type.\n\n");
        if (namelen) free(outname);
        free(buffer);
        return 1;
    }
    printf("\n");

    ptr = snesROM2File(PTR_UNKNOWN, type, header);
    if (((header) && (!buffer[0x01FF]) && (buffer[ptr] == 0xFF)) || ((!header) && (buffer[ptr] == 0xFF))) {
        printf("Error: This SNES ROM is not protected.\n\n");
        if (namelen) free(outname);
        free(buffer);
        return 1;
    }


    // Hack SMC header
    if (header) buffer[0x01FF] = 0;

    // Hack ROM header
    ptr = snesROM2File(HDR_SIZE, type, header);
    i = buffer[ptr];
    memcpy((buffer + snesROM2File(PTR_ROMHEADER, type, header)), headdata, 29);
    buffer[ptr] = i;

    // Miscellaneous hacks
    buffer[snesROM2File(PTR_UNKNOWN, type, header)] = 0xFF;

    // Decrypt miscellaneous pointers
    ptrseeds = snesROM2File(PTR_CRYPTFUNC, type, header);
    ptrseeds = ((buffer[ptrseeds + 2] << 16) | (buffer[ptrseeds + 1] << 8) | buffer[ptrseeds + 0]);
    ptrseeds = snesROM2File(ptrseeds, type, header);
    printf("Miscellaneous encryption seeds: 0x%02X, 0x%02X\n", buffer[ptrseeds + 6], buffer[ptrseeds + 7]);

    ptr = snesROM2File(PTR_CRYPTPTRS, type, header);
    for (i = 0; i < 0x32; i++) {
        buffer[ptr + i + 0x00] ^= buffer[ptrseeds + 6];
        buffer[ptr + i + 0x32] ^= buffer[ptrseeds + 7];
    }

    ptr = snesROM2File(PTR_CRYPTUNK0, type, header);
    buffer[ptr + 0] ^= buffer[ptrseeds + 6];
    buffer[ptr + 1] ^= buffer[ptrseeds + 7];

    ptr = snesROM2File(PTR_CRYPTUNK1, type, header);
    buffer[ptr + 0] ^= buffer[ptrseeds + 6];
    buffer[ptr + 1] ^= buffer[ptrseeds + 7];
    printf("Miscellaneous pointers decrypted\n");

    // Decrypt "ExGFX" pointers
    num = 0;
    ptr = snesROM2File(PTR_EXGFXPTRS, type, header);
    for (i = 0; i < (128 * 3); i += 3) {
        if ((buffer[ptr + i + 2] != 0x00) && (buffer[ptr + i + 2] != 0xFF)) { // Assume this is a valid pointer, if the high byte is not 0 or 255
            buffer[ptr + i + 0] ^= buffer[ptrseeds + 6];
            buffer[ptr + i + 1] ^= buffer[ptrseeds + 7];
            num++;
        }
    }
    if (num) printf("%d ExGFX pointers decrypted\n", num);
    else printf("No ExGFX pointers found\n");

    // Decrypt "Super ExGFX" pointers
    num = 0;
    ptr = snesROM2File(PTR_SEXGFXPTRS, type, header);
    ptr = ((buffer[ptr + 2] << 16) | (buffer[ptr + 1] << 8) | buffer[ptr + 0]);
    if (ptr != 0xFFFFFF) {
        ptr = snesROM2File(ptr, type, header);
        for (i = 0; i < (3840 * 3); i += 3) { // YEP! Lots and lots of these...
            if ((buffer[ptr + i + 2] != 0x00) && (buffer[ptr + i + 2] != 0xFF)) { // Assume this is a valid pointer, if the high byte is not 0 or 255
                buffer[ptr + i + 0] ^= buffer[ptrseeds + 6];
                buffer[ptr + i + 1] ^= buffer[ptrseeds + 7];
                num++;
            }
        }
    }
    if (num) printf("%d Super ExGFX pointers decrypted\n", num);
    else printf("No Super ExGFX pointers found\n");

    // Decrypt overworld pointer
    ptr = snesROM2File(PTR_OVERWORLD, type, header);
    buffer[ptr + 0] ^= buffer[ptrseeds + 6];
    buffer[ptr + 1] ^= buffer[ptrseeds + 7];
    printf("Hard-coded OverWorld pointer decrypted\n");

    // Repair overworld enhancement pointers
    ptr = snesROM2File(PTR_OWPTR, type, header);
    if (buffer[ptr] == 0x02) {
        ptr++;
        memcpy(minibuf, &buffer[ptr], 9);
        memcpy(&buffer[ptr + 5], &minibuf[0], 4); // Strange rotation... hmmm!
        memcpy(&buffer[ptr + 0], &minibuf[4], 5);
        printf("OverWorld Enhancement pointers fixed\n\n");
    }


    // Decrypt stages
    seeds = snesROM2File(PTR_STAGEFUNC, type, header);
    seeds = ((buffer[seeds + 2] << 16) | (buffer[seeds + 1] << 8) | buffer[seeds + 0]);
    seeds = snesROM2File(seeds, type, header);
    printf("Stage data encryption seeds: 0x%02X, 0x%02X\n", buffer[seeds + 7], buffer[seeds + 18]);

    num = 0;
    ptr = snesROM2File(PTR_STAGEPTRS, type, header);
    ptr2 = snesROM2File(PTR_USTAGEPTRS, type, header);
    for (i = 0; i < 512 * 3; i += 3) {
        if (buffer[ptr + i + 2] >= 0x10) { // Stage data needs decrypting if the high byte of the pointer is >= 0x10
            dst = ((buffer[ptr + i + 2] << 16) | (buffer[ptr + i + 1] << 8) | buffer[ptr + i + 0]);
            dst = snesROM2File(dst, type, header);
            printf("Decrypting stage 0x%04X...  [0x%06X]", (i / 3), dst);
            decryptLunar(buffer, (dst + 5), seeds);

            // Decrypt that other part of stage data... (WTF? o_O)
            switch (buffer[dst + 1] & 0x1F) {
                case 0x00: case 0x0A: case 0x0C: case 0x0D:
                case 0x0E: case 0x11: case 0x1E:
                    // Do nothing :)
                    break;
                default:
                    if ((buffer[ptr2 + i + 2] >= 0x10) && (buffer[ptr2 + i + 2] != 0xFF)) {
                        dst = ((buffer[ptr2 + i + 2] << 16) | (buffer[ptr2 + i + 1] << 8) | buffer[ptr2 + i + 0]);
                        dst = snesROM2File(dst, type, header);
                        printf(" [0x%06X]", dst);
                        dst += 5;
                        decryptLunar(buffer, dst, seeds);
                    }
                    break;
            }

            printf("\n");
            num++;
        }
    }
    printf("%d stages decrypted\n\n", num);

    printf("Replacing protection-based assembly hacks...\n");
    memcpy((buffer + snesROM2File(PTR_CRYPTFUNC, type, header) - 1), orgcrypt, 5);
    memcpy((buffer + snesROM2File(PTR_STAGEFUNC, type, header) - 1), orgstage, 5);
    memset((buffer + ptrseeds), 0xFF, 0x11);
    memset((buffer + seeds), 0xFF, 0x14);

    printf("Fixing Checksum...\n");
    snesGenChecksum(buffer, (filesize >> 17), type, header);


    // Create output file
    if (!(fout = fopen(outname, "wb"))) {
        printf("Unable to open output file \"%s\"\n\n", outname);
        if (namelen) free(outname);
        free(buffer);
        return 1;
    }

    // Write output file
    printf("Writing to \"%s\"...\n", outname);
    fwrite(buffer, 1, filesize, fout);
    printf("Done!\n\n");

    if (namelen) free(outname);
    free(buffer);
    fclose(fout);

    return 0;
}
