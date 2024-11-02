// DarkenImage.cpp
#include "pch.h"

extern "C" __declspec(dllexport) void Darken2(unsigned char* pixelData, int length) {

    float darkenFactor = 0.5f;

    for (int i = 0; i < length; i += 3) {
        pixelData[i] = static_cast<unsigned char>(pixelData[i] * darkenFactor);
        pixelData[i + 1] = static_cast<unsigned char>(pixelData[i + 1] * darkenFactor); 
        pixelData[i + 2] = static_cast<unsigned char>(pixelData[i + 2] * darkenFactor);
    }
}
