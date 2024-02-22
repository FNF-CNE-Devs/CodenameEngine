// TO FINISH!!!  - Nex
import flixel.tweens.FlxTweenType;

var aberration:CustomShader = null;
var spirit:FlxSprite;
function postCreate() {
	spirit = new FlxSprite(320, 170).loadGraphic(Paths.image('game/cutscenes/weeb/spiritFaceForward'));
	spirit.setGraphicSize(Std.int(spirit.width * 6));
	if(Options.gameplayShaders) {
		spirit.shader = aberration = new CustomShader('chromaticAberration');
		FlxTween.num(-0.003, 0.003, 3, {ease: FlxEase.sineInOut, type: FlxTweenType.PINGPONG}, function(num) { aberration.redOff = [0, -num]; aberration.blueOff = [0, num]; });
	}
	//spirit.alpha = 0;
	cutscene.add(spirit);
}

function popupChar(event) {
	if(!active || event.char.positionName != "left") return;
	event.char.color = FlxColor.BLACK;
	var pos = positions["left"];
	if (pos == null) return;  // It shouldnt but whatever  - Nex

	//spirit.setPosition((FlxG.width / 2) + pos.x - event.char.offset.x, FlxG.height - pos.y - event.char.offset.y);
}