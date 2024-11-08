#pragma header

uniform float redOff;
uniform float greenOff;
uniform float blueOff;

void main()
{
	vec2 uv = getCamPos(openfl_TextureCoordv);
	vec4 col;
	col.r = textureCam(bitmap, uv + redOff).r;
	col.g = textureCam(bitmap, uv + greenOff).g;
	col.b = textureCam(bitmap, uv + blueOff).b;
	col.a = texture2D(bitmap, openfl_TextureCoordv).a;

	gl_FragColor = col;
}
