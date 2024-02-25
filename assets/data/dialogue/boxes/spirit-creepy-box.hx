import flixel.tweens.FlxTweenType;

var aberration:CustomShader = null;
var spirit:FlxSprite;
function postCreate() {
	spirit = new FlxSprite(320, 170).loadGraphic(Paths.image('game/cutscenes/weeb/spiritFaceForward'));
	spirit.setGraphicSize(Std.int(spirit.width * 6));
	if(Options.gameplayShaders) {
		spirit.shader = aberration = new CustomShader('chromaticAberration');
		FlxTween.num(-0.003, 0.003, 3, {ease: FlxEase.sineInOut, type: FlxTweenType.PINGPONG}, function(num) { if(aberration == null) return; aberration.redOff = [0, -num]; aberration.blueOff = [0, num]; });
	}
	cutscene.add(spirit);

	FlxG.camera._fxFadeAlpha = 0;
	cutscene.dialogueCamera.bgColor = FlxColor.fromRGBFloat(1, 1, 1, 0.3);
}

var finished:Bool = false;
function close(event) {
	if(finished) return;
	else event.cancelled = true;
	cutscene.canProceed = false;

	cutscene.curMusic?.fadeOut(1, 0);
	for(c in cutscene.charMap) c.visible = false;

	spirit.destroy();
	spirit.shader = aberration = null;
	new FlxTimer().start(0.4, function(swagTimer:FlxTimer) {
		cutscene.dialogueCamera.alpha -= 0.15;

		if(cutscene.dialogueCamera.alpha > 0) swagTimer.reset();
		else {
			finished = true;
			cutscene.close();
		}
	});
}

function popupChar(event) {
	if(!active || event.char.positionName != "left") return;
	event.char.color = FlxColor.BLACK;
}