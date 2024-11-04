// DarkenImage.cpp
#include "pch.h"

extern "C" __declspec(dllexport) void Darken2(unsigned char* pixelData, int length) {
    const float lightenFactor = 1.2f;

    for (int i = 0; i < length; i += 3) {
        int blue = static_cast<int>(pixelData[i]) * lightenFactor;
        pixelData[i] = (blue > 255) ? 255 : static_cast<unsigned char>(blue);

        int green = static_cast<int>(pixelData[i + 1]) * lightenFactor;
        pixelData[i + 1] = (green > 255) ? 255 : static_cast<unsigned char>(green);

        int red = static_cast<int>(pixelData[i + 2]) * lightenFactor;
        pixelData[i + 2] = (red > 255) ? 255 : static_cast<unsigned char>(red);
    }
}
