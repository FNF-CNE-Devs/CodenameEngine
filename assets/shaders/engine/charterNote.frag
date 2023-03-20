#pragma header

uniform vec3 noteColor;

void main() {
    vec4 finalColor = flixel_texture2D(bitmap, openfl_TextureCoordv);
    float diff = finalColor.r - ((finalColor.g + finalColor.b) / 2.0);
    gl_FragColor = vec4(((finalColor.g + finalColor.b) / 2.0) + (noteColor.r * diff), finalColor.g + (noteColor.g * diff), finalColor.b + (noteColor.b * diff), finalColor.a);
}