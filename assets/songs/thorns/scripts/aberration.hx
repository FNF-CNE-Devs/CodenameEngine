function create() {
	var aberration:CustomShader = new CustomShader('chromaticAberration');  // Tbh i love it in the cutscene aswell - Nex_isDumb
	var intens = Options.week6PixelPerfect ? 0.0003 : 0.005;
	aberration.redOff = [intens, intens];
	aberration.blueOff = [-intens, -intens];
	camGame.addShader(aberration);
	disableScript();
}