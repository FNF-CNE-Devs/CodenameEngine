#pragma header

uniform float pixelZoom;
// how it works
// - takes the camera
// - unzooms it to make it pixel perfect and align every pixel
// - zooms in the result using this shader
void main() {
	vec2 camPos = getCamPos(openfl_TextureCoordv);

	camPos = vec2(0.5, 0.5) + ((camPos - vec2(0.5, 0.5)) * pixelZoom);

	gl_FragColor = textureCam(bitmap, camPos);
}
