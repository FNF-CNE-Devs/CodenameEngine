function create() {
	if(!playCutscenes) disableScript();
	// Make transition work between school types
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

	var white:FlxSprite = new FlxSprite().makeSolid(FlxG.width, FlxG.height, FlxColor.WHITE);
	white.updateHitbox();
	white.scrollFactor.set();
	white.alpha = 0;
	add(white);

	new FlxTimer().start(3.2, function(deadTime:FlxTimer)
	{
		FlxG.camera.fade(FlxColor.WHITE, 1.6, false, function() {
			remove(senpaiEvil);
			senpaiEvil.destroy();
			remove(red);
			red.destroy();

			white.alpha = 1;
		});
	});
	FlxG.sound.play(Paths.sound('cutscenes/weeb/Senpai_Dies'), 1, false, null, true, function()
	{
		new FlxTimer().start(0.2, function(swagTimer:FlxTimer) {
			white.alpha -= 0.15;

			if(white.alpha > 0) swagTimer.reset();
			else {
				remove(white);
				white.destroy();

				camHUD.visible = true;
				inCutscene = false;
				senpaiFuckingDied = true;
				startCountdown();
			}
		});

		FlxG.camera.fade(FlxColor.WHITE, 0.0001, true);
	});
}