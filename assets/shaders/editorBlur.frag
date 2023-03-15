#pragma header
#define PI 3.14159265359

int steps = 16;
int stepsInside = 2;
float strength = 0.0075;
void main() {
    vec4 color = flixel_texture2D(bitmap, openfl_TextureCoordv);
    float fsteps = steps;
    for(float inside = 1; inside < stepsInside+1; inside++) {
        for(int i = 0; i < steps; i++) {
            float fi = i;
            color += flixel_texture2D(bitmap, openfl_TextureCoordv + vec2(strength * (inside / stepsInside) * cos(fi / fsteps * (PI * 2.0)), strength * (inside / stepsInside) * sin(fi / fsteps * (PI * 2.0))));
        }
    }
    /*
    for(int x = -steps; x < steps+1; x++) {
        for(int y = -steps; y < steps+1; y++) {
            color += flixel_texture2D(bitmap, openfl_TextureCoordv + vec2(strength / steps * x, strength / steps * y));
        }
    }
    */
    color /= steps * stepsInside * 1.25;
    gl_FragColor = color;
}