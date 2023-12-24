#pragma header

uniform vec3 color;
uniform float amount;
uniform float strength;

void main() {
	vec2 uv = getCamPos(openfl_TextureCoordv);
    vec3 col = pow(textureCam(bitmap, uv).rgb, vec3(1.0 / strength));

    float vignette = mix(1.0, 1.0 - amount, distance(uv, vec2(0.5)));
    col = pow(mix(col * color, col, vignette), vec3(strength));

	gl_FragColor = vec4(col, 1.0);
}