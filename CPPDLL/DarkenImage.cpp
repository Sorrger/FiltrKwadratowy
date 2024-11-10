#include "pch.h"
#include <vector>
#include <algorithm>

extern "C" __declspec(dllexport) void Darken2(unsigned char* pixelData, int width, int startY, int segmentHeight) {
    const int maskSize = 5;
    const int halfMask = maskSize / 2;
    const float maskValue = 1.0f / 24.0f;

    std::vector<unsigned char> tempData(pixelData, pixelData + (width * segmentHeight * 3));

    for (int y = halfMask; y < segmentHeight - halfMask; ++y) {
        for (int x = halfMask; x < width - halfMask; ++x) {
            float sumBlue = 0.0f, sumGreen = 0.0f, sumRed = 0.0f;

            for (int dy = -halfMask; dy <= halfMask; ++dy) {
                for (int dx = -halfMask; dx <= halfMask; ++dx) {
                    if (dx == 0 && dy == 0) continue;

                    int nx = x + dx;
                    int ny = y + dy + startY;
                    int index = (ny * width + nx) * 3;

                    sumBlue += tempData[index] * maskValue;
                    sumGreen += tempData[index + 1] * maskValue;
                    sumRed += tempData[index + 2] * maskValue;
                }
            }

            int currentIndex = ((y + startY) * width + x) * 3;
            pixelData[currentIndex] = static_cast<unsigned char>(fminf(255.0f, sumBlue));
            pixelData[currentIndex + 1] = static_cast<unsigned char>(fminf(255.0f, sumGreen));
            pixelData[currentIndex + 2] = static_cast<unsigned char>(fminf(255.0f, sumRed));
        }
    }
}

