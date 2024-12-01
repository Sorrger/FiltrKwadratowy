#include "pch.h"
#include <vector>
#include <algorithm>

extern "C" __declspec(dllexport) void Darken2(unsigned char* pixelData, int width, int startY, int endY, int imageHeight) {
    const int maskSize = 5;
    const int halfMask = maskSize / 2;
    const float maskValue = 1.0f / 25.0f;

    // Iterujemy po wierszach od startY do endY
    for (int y = startY; y < endY; ++y) {
        for (int x = 0; x < width; ++x) {
            float sumBlue = 0.0f, sumGreen = 0.0f, sumRed = 0.0f;

            for (int dy = -halfMask; dy <= halfMask; ++dy) {
                for (int dx = -halfMask; dx <= halfMask; ++dx) {
                    int nx = x + dx;
                    int ny = y + dy;

                    if (nx >= 0 && nx < width && ny >= 0 && ny < imageHeight) {
                        int index = (ny * width + nx) * 3;
                        sumBlue += pixelData[index] * maskValue;
                        sumGreen += pixelData[index + 1] * maskValue;
                        sumRed += pixelData[index + 2] * maskValue;
                    }
                }
            }

            int index = (y * width + x) * 3;
            pixelData[index] = static_cast<unsigned char>(std::clamp(sumBlue, 0.0f, 255.0f));
            pixelData[index + 1] = static_cast<unsigned char>(std::clamp(sumGreen, 0.0f, 255.0f));
            pixelData[index + 2] = static_cast<unsigned char>(std::clamp(sumRed, 0.0f, 255.0f));
        }
    }
}
