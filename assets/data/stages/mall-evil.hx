function create() {
	if(!Options.gameplayShaders) return;
	var idk = new CustomShader('coloredVignette');
	idk.color = [1, 0, 0];
	idk.amount = 0.5;
	idk.strength = 6;
	camGame.addShader(idk);
}