#pragma header

vec3 hsvToRgb(vec3 hsv){ //hsv.x = hue, hsv.y = saturation, hsv.z = value
	vec3 col = vec3(hsv.x, hsv.x + 2.0/3.0, hsv.x + 4.0/3.0); //inputs for r, g, and b
	col = clamp(abs(mod(col*2.0, 2.0)-1.0)*3.0 - 1.0, 0.0, 1.0)*hsv.z*hsv.y + hsv.z - hsv.z*hsv.y; //hue function (graph it on desmos)
	return col;
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