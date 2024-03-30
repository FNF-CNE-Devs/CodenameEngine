#pragma header

// Used for editors (faster)

//#define iResolution _camSize
#define getTexture textureCam

#define iResolution openfl_TextureSize
//#define getTexture flixel_texture2D

float uBlur = 0.015;
float uBrightness = 0.6;

vec4 getColor(vec2 pos) {
	vec2 ps = (pos);
	if (ps.x < 0.0) ps.x = 0.0;
	//else if (ps.x > 1.0 - (1.0 / iResolution.x)) ps.x = 1.0 - (1.0 / iResolution.x);
	else if (ps.x > 1.0) return vec4(0.0);
	if (ps.y < 0.0) ps.y = 0.0;
	//else if (ps.y > 1.0 - (1.0 / iResolution.y)) return ps.y = 1.0 - (1.0 / iResolution.y);
	else if (ps.y > 1.0) return vec4(0.0);
	return flixel_texture2D(bitmap, (ps));
}


vec2 fixvec2(float x, float y) { // makes an uv the same across sizes
	vec2 val = vec2(x, y);
	val.xy *= vec2(1280.0, 720.0);
	val.xy /= iResolution.xy;
	return val;
}
vec2 fixvec2(vec2 uv) { // makes an uv the same across sizes
	vec2 val = uv;
	val.xy *= vec2(1280.0, 720.0);
	val.xy /= iResolution.xy;
	return val;
}

vec2 random(vec2 p) {
	p = vec2(dot(p,vec2(127.1,311.7)),dot(p,vec2(269.5,183.3)));
	return fract(sin(p)*4375.5);
}

void main() {
	vec2 camPos = (openfl_TextureCoordv);
	//vec2 camPos = openfl_TextureCoordv;
	if (camPos.x < 0.0 || camPos.x > 1.0 || camPos.y < 0.0 || camPos.y > 1.0)
		return;

	//vec4 color = getColor(camPos);

	vec2 blur = vec2(uBlur) * vec2(1.0, iResolution.x / iResolution.y);

	vec4 a = getColor(camPos+(random(camPos)*blur - blur / 2.0)) * uBrightness;
	a += getColor(camPos+(random(camPos+0.1)*blur - blur / 2.0)) * uBrightness;
	a += getColor(camPos+(random(camPos+0.2)*blur - blur / 2.0)) * uBrightness;
	//a += getColor(camPos+(random(camPos+0.3)*blur - blur / 2.0)) * uBrightness;
	gl_FragColor = a / 3.0;
}