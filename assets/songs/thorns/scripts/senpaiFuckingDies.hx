function create() {
	if(!playCutscenes) disableScript();
	if(PlayState.smoothTransitionData?.stage == "school") PlayState.smoothTransitionData.stage = curStage;
}

var senpaiFuckingDied:Bool = false;
function onStartCountdown(bitch) {
	if(!senpaiFuckingDied) bitch.cancel();
}

function postCreate() {
	inCutscene = true;
	camHUD.visible = false;

	var red:FlxSprite = new FlxSprite().makeSolid(FlxG.width, FlxG.height, FlxColor.RED);
	red.updateHitbox();
	red.scrollFactor.set();
	add(red);

	var senpaiEvil:FlxSprite = new FlxSprite();
	senpaiEvil.frames = Paths.getSparrowAtlas('game/cutscenes/weeb/senpaiCrazy');
	senpaiEvil.animation.addByPrefix('idle', 'Senpai Pre Explosion', 24, false);
	senpaiEvil.animation.play('idle');
	senpaiEvil.setGraphicSize(Std.int(senpaiEvil.width * daPixelZoom));
	senpaiEvil.scrollFactor.set();
	senpaiEvil.updateHitbox();
	senpaiEvil.screenCenter();
	senpaiEvil.x += daPixelZoom * 51;
	add(senpaiEvil);

	new FlxTimer().start(3.2, function(deadTime:FlxTimer)
	{
		FlxG.camera.fade(FlxColor.WHITE, 1.6, false);
	});
	FlxG.sound.play(Paths.sound('cutscenes/weeb/Senpai_Dies'), 1, false, null, true, function()
	{
		remove(senpaiEvil);
		senpaiEvil.destroy();
		remove(red);
		red.destroy();
		FlxG.camera.fade(FlxColor.WHITE, 0.01, true, function()
		{
			camHUD.visible = true;
			inCutscene = false;
			senpaiFuckingDied = true;
			startCountdown();
		}, true);
	});
}