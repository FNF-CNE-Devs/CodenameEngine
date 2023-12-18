static var roses_shouldPlayOnThorns = false;
var self = this;
__script__.setParent(PlayState.instance);

function create() {
	var red:FlxSprite;
	red = new FlxSprite().makeSolid(FlxG.width + 100, FlxG.height + 100, FlxColor.RED);
	red.screenCenter();
	red.scrollFactor.set();
	red.alpha = 0;
	add(red);

	// reorder dad
	remove(dad);
	insert(PlayState.instance.members.indexOf(red) + 1, dad);

	playDadUpdate = true;
	dad.playAnim("idle", true);
	dad.animation.finishCallback = (name:String) -> {
		if(name == "idle") {
			dad.animation.finishCallback = null;
			playDadUpdate = false;

			new FlxTimer().start(0.3, function(swagTimer:FlxTimer) {
				red.alpha += 0.15;
				camHUD.alpha -= 0.15;
				var c = FlxMath.lerp(255, 0, red.alpha);
				dad.color = FlxColor.fromRGB(c, c, c, 255);
				if(red.alpha < 1) swagTimer.reset();
				else {
					FlxG.camera.followLerp = 0;
					FlxTween.tween(camGame.scroll, {x: -366, y: 192}, 1.4, {
						ease: FlxEase.quartInOut,
						onComplete: (_) -> {
							roses_shouldPlayOnThorns = true;
							self.close();
						}
					});
				}
			});
		}
	}
}

var playDadUpdate = false;
function postUpdate(elapsed) {
	if(playDadUpdate)
		dad.update(elapsed);
}