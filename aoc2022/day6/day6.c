#include <stdio.h>
#include <stdint.h>
#include <stdbool.h>
#include <stdlib.h>


long solve(char* buffer, long length, unsigned int num_consec_chars) {
    uint32_t counter = 0;
    bool found_flag = 1;
    for (long i = 0; i < length - num_consec_chars; i++) {
        counter = 0;
        found_flag = 1;
        
        for (long j = i; j < i + num_consec_chars; j++) {
            char curr = buffer[j];
            char alpha_index = curr - 97;
            uint32_t new_counter = counter | (1 << alpha_index);
            if (new_counter == counter) {
                found_flag = 0;
                break;
            } else {
                counter = new_counter;
            }
        }

        if (!found_flag) {
            continue;
        }

        // printf("found substring: ");
        // for (long j = i; j < i + num_consec_chars; j++) {
        //     printf("%c", buffer[j]);
        // }
        // printf("\n");

        return i + num_consec_chars;
    }

    return -1;
}

int main(int argc, char *argv[]) {
    if (argc <= 1) {
        return 1;
    }

    char* buffer = 0;
    FILE* f = fopen(argv[1], "rb");

    if (!f) {
        printf("Could not open file\n");
        return 1;
    }

    fseek(f, 0, SEEK_END);
    long length = ftell(f);
    fseek(f, 0, SEEK_SET);

    buffer = malloc(length);
    if (buffer) {
        fread(buffer, 1, length, f);
    }
    
    fclose(f);
    
    if (!buffer) {
        printf("Could not read file into buffer\n");
        return 1;
    }

    printf("Part 1: %ld\n", solve(buffer, length, 4));
    printf("Part 2: %ld\n", solve(buffer, length, 14));
}