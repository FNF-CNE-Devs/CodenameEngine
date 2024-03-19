#pragma header
#extension GL_EXT_gpu_shader4 : enable

// Used in charter by waveforms -lunar

uniform vec2 textureRes;

uniform sampler2D waveformTexture;
uniform ivec2 waveformSize;

float getAmplitude() {
	float amplitudeRet = 0.; // look in charter for more how it works -lunar

	vec2 pixel = openfl_TextureCoordv * textureRes;
	float pixelID = floor(pixel.y/3.);
	
	vec2 wavePixel = vec2(int(pixelID)%waveformSize.x, floor(pixelID/waveformSize.x));
	vec4 waveData = texture2D(waveformTexture, wavePixel / waveformSize);

	switch (int(pixel.y) % 3) {
		case 0: amplitudeRet = waveData.r; break;
		case 1: amplitudeRet = waveData.g; break;
		case 2: amplitudeRet = waveData.b; break;
	}
	return amplitudeRet;
}

void main()
{
	gl_FragColor = vec4(vec3(getAmplitude()), 1.);
}