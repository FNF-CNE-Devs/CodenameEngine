#pragma header

// Used in colorwheel

vec3 hsvToRgb(vec3 c) { //hsv.x = hue, hsv.y = saturation, hsv.z = value
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

uniform float hue;

void main()
{
	vec2 uv = openfl_TextureCoordv.xy;
	vec4 col = texture2D(bitmap, uv);

	if (col.a > 0.0)
		col = vec4(hsvToRgb(vec3(hue, uv.x, 1.0-uv.y)), 0.0);

	gl_FragColor = col;
}