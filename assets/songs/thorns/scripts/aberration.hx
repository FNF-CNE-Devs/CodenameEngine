var aberration:CustomShader = new CustomShader('chromaticAberration');
function create() {
	setGeneralIntensity(Options.week6PixelPerfect ? 0.0005 : 0.005);
	camGame.addShader(aberration);
}

var intens:Float = 0;
function setGeneralIntensity(val:Float) {
	intens = val;
	aberration.redOff = [intens, 0];
	aberration.blueOff = [-intens, 0];
}

var canBump:Bool = false;
function aberrationCoolThing() {
	canBump = !canBump;
	if(!canBump) setGeneralIntensity(Options.week6PixelPerfect ? 0.0005 : 0.005);  // Just to make sure if anything goes wrong  - Nex_isDumb
}

function update(elapsed:Float) {
	if(canBump && intens > (Options.week6PixelPerfect ? 0.0005 : 0.005)) setGeneralIntensity(intens - (Options.week6PixelPerfect ? 0.0001 : 0.001));
}

function beatHit(curBeat:Float) {
	if(canBump && curBeat % 2 != 0) setGeneralIntensity(Options.week6PixelPerfect ? 0.005 : 0.05);
}