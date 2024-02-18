package funkin.game.cutscenes.dialogue;

import flixel.tweens.FlxTween;
import haxe.xml.Access;

class DialogueCharacter extends FunkinSprite {
	public var charData:Access;
	public var curTween:FlxTween;
	public var curAnimContext:DialogueCharAnimContext = NONE;
	public var positionName:String;
	public var finishCallback:String->Void = null;

	public function new(name:String, position:String) {
		super();
		this.positionName = position;
		try {
			charData = new Access(Xml.parse(Assets.getText(Paths.xml('dialogue/characters/$name'))).firstElement());
			if(!charData.has.sprite) charData.x.set("sprite", name);
			if(!charData.has.updateHitbox) charData.x.set("updateHitbox", "true");
			XMLUtil.loadSpriteFromXML(this, charData, "dialogue/characters/", LOOP);

			animation.finishCallback = (name:String) -> {
				switch(name)
				{
					case 'show': hasAnimation('normal') ? playAnim('normal', true) : animation.stop();
					case 'hide': alpha = 0;
				}
				if(finishCallback != null) finishCallback(name);
			}

			offset.set(x, y + height);
			x = 0; y = 0;
		} catch(e) {
			Logs.trace('Failed to load dialogue character $name: ${e.toString()}', ERROR);
		}
		visible = false;
	}

	public function show(x:Float, y:Float) {
		if (curAnimContext == (curAnimContext = POPIN)) return;

		visible = true;
		if (hasAnimation('show')) {
			playAnim('show', true);
			setPosition(x, y);
			alpha = 1;
		} else {
			setPosition(x, y + 100);
			if(curTween != null) curTween.cancel();
			playAnim('normal', true);
			alpha = 0;
			curTween = FlxTween.tween(this, {alpha: 1, y: y}, 0.2, {ease: FlxEase.quintOut});
		}
	}

	public function hide() {
		if (curAnimContext == (curAnimContext = POPOUT)) return;

		if(hasAnimation('hide')) playAnim('hide', true);
		else {
			if(curTween != null) curTween.cancel();
			curTween = FlxTween.tween(this, {alpha: 0, y: y + 100}, 0.2, {ease: FlxEase.quintIn});
		}
	}
}

enum abstract DialogueCharAnimContext(Int) {
	var NONE = -1;
	var POPIN = 0;
	var POPOUT = 1;
}