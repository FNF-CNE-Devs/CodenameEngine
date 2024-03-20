#pragma header
#extension GL_EXT_gpu_shader4 : enable

// Used in charter by waveforms -lunar

uniform vec2 textureRes;

uniform sampler2D waveformTexture;
uniform ivec2 waveformSize;

float getAmplitude(vec2 pixel) {
	float amplitudeRet = 0.; // look in charter for more how it works -lunar

	float pixelID = floor(pixel.y/3.);
	
	vec2 wavePixel = vec2(mod(pixelID, waveformSize.x), floor(pixelID/waveformSize.x));
	vec4 waveData = texture2D(waveformTexture, wavePixel / waveformSize);

	switch (int(round(mod(wavePixel.x, 3.)))) {
		case 0: amplitudeRet = waveData.r; break;
		case 1: amplitudeRet = waveData.g; break;
		case 2: amplitudeRet = waveData.b; break;
	}
	return amplitudeRet;
}

void main()
{
	vec2 pixel = openfl_TextureCoordv * textureRes;
	float amplitude = getAmplitude(pixel);
	float ampwidth = (1.-amplitude) * textureRes.x;

	gl_FragColor = vec4(0.); // transprenty

	if (pixel.x > (ampwidth/2.) && pixel.x < (textureRes.x-(ampwidth/2.))) {
		vec3 waveColor = vec3(0.);
		float outline = 2.;

		if (pixel.x > ((ampwidth-outline)/2.) && pixel.x < (textureRes.x-((ampwidth-outline)/2.)))
			waveColor = vec3(openfl_TextureCoordv.x);

		gl_FragColor = vec4(waveColor, 1.);
	}
}