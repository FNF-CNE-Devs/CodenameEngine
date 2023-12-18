function create() {
	if(!playCutscenes) disableScript();
}

var red:FlxSprite;
function postCreate() {
	red = new FlxSprite().makeSolid(FlxG.width, FlxG.height, FlxColor.RED);
	red.updateHitbox();
	red.scrollFactor.set();
	red.alpha = 0;
}

var forceEndIdle = false;
function postUpdate() {
	if(forceEndIdle) {
		dad.playAnim("idle", true);
		dad.animation.curAnim.curFrame = dad.animation.curAnim.numFrames-1;
	}
}

function onSongEnd(shut) {
	shut.cancel();
	inCutscene = true;
	add(red);
	remove(dad);
	insert(PlayState.instance.members.indexOf(red) + 1, dad);

	dad.playAnim("idle", true);
	dad.animation.finishCallback = (name:String) -> {
		if(name == "idle") {
			dad.animation.finishCallback = null;
			forceEndIdle = true;

			new FlxTimer().start(0.3, function(swagTimer:FlxTimer) {
				red.alpha += 0.15;
				camHUD.alpha -= 0.15;
				var c = FlxMath.lerp(255, 0, red.alpha);
				dad.color = FlxColor.fromRGB(c, c, c, 255);
				if(red.alpha < 1) swagTimer.reset();
				else {
					inCutscene = false;
					FlxG.camera.followLerp = 0;
					FlxTween.tween(camGame.scroll, {x: -366, y: 192}, 1.4, {
						ease: FlxEase.quartInOut,
						onComplete: (_) -> {
							nextSong();
						}
					});
				}
			});
		}
	}
}