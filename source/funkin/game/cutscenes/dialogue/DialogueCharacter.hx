package funkin.game.cutscenes.dialogue;

import flixel.tweens.FlxTween;
import haxe.xml.Access;

class DialogueCharacter extends FunkinSprite {
	public var charData:Access;
	public var curTween:FlxTween;
	public var curTweenContext:DialogueCharTweenContext = NONE;
	public var positionName:String;

	public function new(name:String, position:String) {
		super();
		this.positionName = position;
		try {
			charData = new Access(Xml.parse(Assets.getText(Paths.xml('dialogue/characters/$name'))).firstElement());
			loadSprite(Paths.image('dialogue/characters/${charData.getAtt('sprite').getDefault(name)}'));
			antialiasing = charData.getAtt('antialiasing').getDefault('true') == 'true';
			scale.scale(charData.has.scale ? Std.parseFloat(charData.att.scale).getDefault(1) : 1);
			updateHitbox();
			offset.set(
				charData.has.x ? Std.parseFloat(charData.att.x).getDefault(0) : 0,
				(charData.has.y ? Std.parseFloat(charData.att.y).getDefault(0) : 0) + this.height);
			for(anim in charData.nodes.anim)
				XMLUtil.addXMLAnimation(this, anim, true);
		} catch(e) {
			Logs.trace('Failed to load dialogue character $name: ${e.toString()}', ERROR);
		}
		visible = false;
	}

	public function show(x:Float, y:Float) {
		if (curTweenContext != (curTweenContext = POPIN)) {
			setPosition(x, y + 100);
			if (curTween != null)
				curTween.cancel();

			alpha = 0;
			visible = true;
	
			curTween = FlxTween.tween(this, {alpha: 1, y: y}, 0.2, {ease: FlxEase.quintOut});
		}
	}

	public function hide() {
		if (curTweenContext != (curTweenContext = POPOUT)) {
			if (curTween != null)
				curTween.cancel();
	
			curTween = FlxTween.tween(this, {alpha: 0, y: y + 100}, 0.2, {ease: FlxEase.quintIn});
		}
	}
}

enum abstract DialogueCharTweenContext(Int) {
	var NONE = -1;
	var POPIN = 0;
	var POPOUT = 1;
}