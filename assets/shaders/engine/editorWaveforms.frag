#pragma header
#extension GL_EXT_gpu_shader4 : enable

// Used in charter by waveforms -lunar

const vec3 gradient1 = vec3(114./255., 81./255., 135./255);
const vec3 gradient2 = vec3(144./255., 80./255., 186./255);

const vec4 outlinecolor = vec4(vec3(.1), .1);
const vec3 lowdetailcol = vec3(0., 0., 1.);

uniform vec2 textureRes;
uniform float pixelOffset;

uniform float playerPosition;

uniform sampler2D waveformTexture;
uniform ivec2 waveformSize;

uniform bool lowDetail;

float getAmplitude(vec2 pixel) {
	float pixelID = floor((pixel.y+pixelOffset)/3.);
	
	// TODO: INVESTIGATE THE 1.+ AND WHY IT WORKS (SRSLY I GOT NO CLUE) -lunar
	vec2 wavePixel = vec2(int(pixelID)%waveformSize.x, 1.+floor(pixelID/waveformSize.x));
	vec4 waveData = texture2D(waveformTexture, wavePixel / waveformSize);

	switch (int(wavePixel.x)%3) {
		case 0: return waveData.r; break;
		case 1: return waveData.g; break;
		case 2: return waveData.b; break;
	}
	return 0.;
}

bool inWaveForm(vec2 pixel, float width) {
	float widthdiv2 = width/2.;
	return pixel.x > widthdiv2 && pixel.x < textureRes.x-widthdiv2;
}

void highDetailWaveform(vec2 pixel, float amplitude, float ampwidth) {
	if (inWaveForm(pixel, ampwidth)) {
		vec3 gradientColor = mix(gradient1, gradient2, openfl_TextureCoordv.x);
		gradientColor *= pixel.y+pixelOffset>playerPosition ? .7 : 1.;

		float ampwidthHighlightCool = (1.-(amplitude)) * textureRes.x;
		float remapCoord = (ampwidthHighlightCool/textureRes.x)/2.;

		float mappedCoord = map(openfl_TextureCoordv.x, remapCoord, 1.-remapCoord, 0., 1.);
		float hightlightAmount = 1.-(abs(mappedCoord-0.5)*2.);

		gradientColor = mix(gradientColor, gradientColor * vec3(1.8), map(hightlightAmount, 0., 1., .5, 1.));

		float ampwidthHighlight = (1.-(amplitude*(1./3.))) * textureRes.x;
		if (inWaveForm(pixel, ampwidthHighlight)) {
			float remapCoord = (ampwidthHighlight/textureRes.x)/2.;

			float mappedCoord = map(openfl_TextureCoordv.x, remapCoord, 1.-remapCoord, 0., 1.);
			float hightlightAmount = 1.-(abs(mappedCoord-0.5)*2.);

			gradientColor = mix(gradientColor, gradientColor * vec3(1.8), map(hightlightAmount, 0., 1., .5, 1.));
		}
		
		gl_FragColor = vec4(vec3(gradientColor * mix(0.5, .8, amplitude))*openfl_Alphav, openfl_Alphav);

		float lastAmplitude = getAmplitude(pixel - vec2(0., -1.));
		float lastAmpwidth = (1.-lastAmplitude) * textureRes.x;

		if (!inWaveForm(pixel, lastAmpwidth))
			gl_FragColor -= outlinecolor*mix(0.5, .8, amplitude);

		float nextAmplitude = getAmplitude(pixel - vec2(0., 1.));
		float nextAmpwidth = (1.-nextAmplitude) * textureRes.x;

		if (!inWaveForm(pixel, nextAmpwidth))
			gl_FragColor -= outlinecolor*mix(0.5, .8, amplitude);

		if (!inWaveForm(pixel, ampwidth+2.) && amplitude > 0.)
	 		gl_FragColor -= outlinecolor;
	}
}

void lowDetailWaveform(vec2 pixel, float amplitude, float ampwidth) {
	if (inWaveForm(pixel, ampwidth)) {
		vec3 color = lowdetailcol;
		color *= pixel.y+pixelOffset>playerPosition ? .6 : 1.;

		gl_FragColor = vec4(color, 1.);
	}
}

void main()
{
	vec2 pixel = openfl_TextureCoordv * textureRes;

	float amplitude = getAmplitude(pixel);
	float ampwidth = (1.-amplitude) * textureRes.x;

	if (lowDetail)
		lowDetailWaveform(pixel, amplitude, ampwidth);
	else 
		highDetailWaveform(pixel, amplitude, ampwidth);
}