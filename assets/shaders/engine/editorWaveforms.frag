#pragma header
#extension GL_EXT_gpu_shader4 : enable

// Used in charter by waveforms -lunar

uniform vec2 textureRes;
uniform float pixelOffset;

uniform sampler2D waveformTexture;
uniform ivec2 waveformSize;

float getAmplitude(vec2 pixel) {
	float amplitudeRet = 0.; // look in charter for more how it works -lunar

	float pixelID = floor((pixel.y+pixelOffset)/3.);
	
	vec2 wavePixel = vec2(mod(pixelID, waveformSize.x), floor(pixelID/waveformSize.x));
	vec4 waveData = texture2D(waveformTexture, wavePixel / waveformSize);

	switch (int(round(mod(wavePixel.x, 3.)))) {
		case 0: amplitudeRet = waveData.r; break;
		case 1: amplitudeRet = waveData.g; break;
		case 2: amplitudeRet = waveData.b; break;
	}
	return amplitudeRet;
}

bool inWaveForm(vec2 pixel, float width) {
	float widthdiv2 = width/2.;
	return pixel.x > widthdiv2 && pixel.x < textureRes.x-widthdiv2;
}

float getAmplitudePixel(vec2 pixel, vec2 offset) {
	return getAmplitude(pixel + offset);
}

const vec3 gradient1 = vec3(114./255., 81./255., 135./255);
const vec3 gradient2 = vec3(144./255., 80./255., 186./255);

void main()
{
	vec2 pixel = openfl_TextureCoordv * textureRes;

	float amplitude = getAmplitude(pixel);
	float ampwidth = (1.-amplitude) * textureRes.x;

	gl_FragColor = vec4(0.);

	if (inWaveForm(pixel, ampwidth)) {
		vec3 gradientColor = mix(gradient1, gradient2, openfl_TextureCoordv.x);

		float ampwidthHighlight = (1.-(amplitude*(1./3.))) * textureRes.x;
		if (inWaveForm(pixel, ampwidthHighlight)) {
			float remapCoord = (ampwidthHighlight/textureRes.x)/2.;

			float mappedCoord = map(openfl_TextureCoordv.x, remapCoord, 1.-remapCoord, 0., 1.);
			float hightlightAmount = 1.-(abs(mappedCoord-0.5)*2.);

			gradientColor = mix(gradientColor, gradientColor * vec3(1.8), map(hightlightAmount, 0., 1., .4, 1.));
		}
		gl_FragColor = vec4(vec3(gradientColor * mix(0.5, .8, amplitude))*openfl_Alphav, openfl_Alphav);
	}
}