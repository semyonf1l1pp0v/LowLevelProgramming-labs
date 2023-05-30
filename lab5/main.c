#include <stdlib.h>
#include <time.h>
#include <string.h>

#define STB_IMAGE_IMPLEMENTATION

#include "stb/stb_image.h"

#define STB_IMAGE_WRITE_IMPLEMENTATION

#include "stb/stb_image_write.h"

unsigned char *grey(unsigned char *img, unsigned char *new_img, int img_size, int channels);

unsigned char *grey_asm(unsigned char *img, unsigned char *new_img, int img_size, int channels);

int format(char *filename, char *format) {
    char *dot_pos;
    for (dot_pos = filename + strlen(filename) - 1; dot_pos >= filename; dot_pos--) {
        if (*dot_pos == '.')
            break;
    }
    return strcmp(dot_pos, format) == 0;
}

int main(int argc, char **argv) {

    if (argc < 3) {
        printf("Usage: %s input_filename output_filename\n", argv[0]);
        return 0;
    }

    char *input = argv[1], *output = argv[2];

    															// Opredelyaem format faila. Esli ne .jpeg to error

    if (!format(input, ".jpeg")) {
        printf("Error, input file format is not .jpeg");
        return 1;
    }

    if (!format(output, ".jpeg")) {
        printf("Error, output file format is not .jpeg");
        return 1;
    }

    															// Load image
    int width, height, channels;
    unsigned char *img = stbi_load(input, &width, &height, &channels, 0);
    if (img == NULL) {
        printf("Error in loading the image\n");
        return 2;
    }

    printf("Loaded image with a width of %dpx, a height of %dpx and %d channels\n", width, height, channels);

    															// Allocate memory for new image
    int img_size = width * height * channels, g_img_size = width * height * channels;
    unsigned char *g_img = malloc(g_img_size);
    if (g_img == NULL) {
        printf("Unable to allocate memory for the new image.\n");
        return 3;
    }

    clock_t begin_time, end_time;
    begin_time = clock();
    g_img = grey(img, g_img, img_size, channels);
    begin_time = clock() - begin_time;
    printf("time C function %.7lf seconds\n", ((double) begin_time) / CLOCKS_PER_SEC);

    printf("Working asm function...\n");
    end_time = clock();
    g_img = grey_asm(img, g_img, img_size, channels);
    end_time = clock() - end_time;
    printf("time asm function %.7lf seconds\n", ((double) end_time) / CLOCKS_PER_SEC);
    															// Saving image

    stbi_write_jpg(output, width, height, channels, g_img, 0);

    															// Free memory
    free(img);
    free(g_img);
    return 0;
}

