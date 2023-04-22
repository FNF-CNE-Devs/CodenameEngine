#pragma header
#define PI 3.14159265359

int steps = 16;
int stepsInside = 2;
float strength = 0.0075;
vec4 getColor(vec2 pos) {
    if (pos.x < 0) pos.x = 0;
    else if (pos.x > 1.0 - (1.0 / openfl_TextureSize.x)) pos.x = 1.0 - (1.0 / openfl_TextureSize.x);
    if (pos.y < 0) pos.y = 0;
    else if (pos.y > 1.0 - (1.0 / openfl_TextureSize.y)) pos.y = 1.0 - (1.0 / openfl_TextureSize.y);
    return textureCam(bitmap, pos);
}
void main() {
    vec2 camPos = getCamPos(openfl_TextureCoordv);
    if (camPos.x < 0 || camPos.x > 1 || camPos.y < 0 || camPos.y > 1)
        return;

    vec4 color = getColor(camPos);
    float fsteps = steps;
    for(float inside = 1; inside < stepsInside+1; inside++) {
        for(int i = 0; i < steps; i++) {
            float fi = i;
            color += getColor(camPos + vec2(strength * (inside / stepsInside) * cos(fi / fsteps * (PI * 2.0)), strength * (inside / stepsInside) * sin(fi / fsteps * (PI * 2.0))));
        }
    }
    
    color /= steps * stepsInside;
    gl_FragColor = color;
}