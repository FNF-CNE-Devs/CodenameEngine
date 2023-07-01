#pragma header

float uBlur = 0.075;
float uBrightness = 0.9;

vec4 getColor(vec2 pos) {
	if (pos.x < 0) pos.x = 0;
	else if (pos.x > 1.0 - (1.0 / openfl_TextureSize.x)) pos.x = 1.0 - (1.0 / openfl_TextureSize.x);
	if (pos.y < 0) pos.y = 0;
	else if (pos.y > 1.0 - (1.0 / openfl_TextureSize.y)) pos.y = 1.0 - (1.0 / openfl_TextureSize.y);
	// return textureCam(bitmap, pos);
	return flixel_texture2D(bitmap, pos);
}

vec2 fixvec2(float x, float y) { // makes an uv the same across sizes
	vec2 val = vec2(x, y);
	val.xy *= vec2(1280.0, 720.0);
	val.xy /= openfl_TextureSize.xy;
	return val;
}
vec2 fixvec2(vec2 uv) { // makes an uv the same across sizes
	vec2 val = uv;
	val.xy *= vec2(1280.0, 720.0);
	val.xy /= openfl_TextureSize.xy;
	return val;
}

vec2 random(vec2 p) {
	p = vec2(dot(p,vec2(127.1,311.7)),dot(p,vec2(269.5,183.3)));
	return fract(sin(p)*4375.5);
}

void main() {
	// vec2 camPos = getCamPos(openfl_TextureCoordv);
	vec2 camPos = openfl_TextureCoordv;
	if (camPos.x < 0 || camPos.x > 1 || camPos.y < 0 || camPos.y > 1)
		return;

	//vec4 color = getColor(camPos);

	vec2 blur = vec2(uBlur) * vec2(1.0, openfl_TextureSize.x / openfl_TextureSize.y);

	vec4 a = getColor(camPos+fixvec2(random(camPos)*blur - blur / 2.0)) * uBrightness;
	a += getColor(camPos+fixvec2(random(camPos+0.1)*blur - blur / 2.0)) * uBrightness;
	a += getColor(camPos+fixvec2(random(camPos+0.2)*blur - blur / 2.0)) * uBrightness;
	//a += getColor(camPos+fixvec2(random(camPos+0.3)*blur - blur / 2.0)) * uBrightness;
	gl_FragColor = a / 4.0;
}