#include <stdio.h>

unsigned char max(unsigned char a, unsigned char b, unsigned char c) {
    if (a > b) {
        if (a > c)
            return a;
        else
            return c;
    } else {
        if (b > c)
            return b;
        else
            return c;
    }
}

unsigned char *grey(unsigned char *img, unsigned char *new_img, int img_size, int channels) {
    for (int i = 0; i < img_size; i += channels) {
        unsigned char red, green, blue, m;
        red = img[i];
        green = img[i + 1];
        blue = img[i + 2];
        m = max(red, green, blue);
        for (int j = 0; j < 3; j++)
            new_img[i + j] = m;
    }
    return new_img;
}
