function create() {
	var aberration:CustomShader = new CustomShader('chromaticAberration');  // Tbh its not even visible in the cutscene so i can just leave it there  - Nex_isDumb
	aberration.redOff = [0.0009, 0.0009];
	aberration.greenOff = [0, 0];
	aberration.blueOff = [-0.0009, -0.0009];
	camGame.addShader(aberration);
	disableScript();
}