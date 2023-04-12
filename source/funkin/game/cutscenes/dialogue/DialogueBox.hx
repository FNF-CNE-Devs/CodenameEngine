package funkin.game.cutscenes.dialogue;

import flixel.addons.text.FlxTypeText;
import flixel.text.FlxText;
import flixel.math.FlxPoint;
import haxe.xml.Access;

class DialogueBox extends FunkinSprite {
	public var dialogueBoxData:Access;
	public var positions:Map<String, CharPosDef> = [];

	public var textTypeSFX:String = Paths.sound('dialogue/text');
	public var nextSFX:String = Paths.sound('dialogue/next');

	public var text:FlxTypeText;

	public function new(name:String) {
		super();
		try {
			dialogueBoxData = new Access(Xml.parse(Assets.getText(Paths.xml('dialogue/boxes/$name'))).firstElement());

			loadSprite(Paths.image('dialogue/boxes/${dialogueBoxData.getAtt('sprite').getDefault(name)}'));

			for(anim in dialogueBoxData.nodes.anim) {
				if (!anim.has.name) continue;
				XMLUtil.addXMLAnimation(this, anim);
			}

			for(pos in dialogueBoxData.nodes.charpos) {
				if (!pos.has.name) continue;
				positions[pos.att.name] = {
					x: pos.has.x ? Std.parseFloat(pos.att.x).getDefault(0) : 0,
					y: pos.has.y ? Std.parseFloat(pos.att.y).getDefault(0) : 0,
					flipBubble: pos.getAtt('flipBubble') == "true"
				};
			}

			if (dialogueBoxData.has.textSound) textTypeSFX = Paths.sound(dialogueBoxData.att.textSound);
			if (dialogueBoxData.has.nextSound) nextSFX = Paths.sound(dialogueBoxData.att.nextSound);

			antialiasing = dialogueBoxData.getAtt("antialiasing").getDefault("true") == "true";
			screenCenter(X);
			y = FlxG.height - height;
			if (dialogueBoxData.has.x) x += Std.parseFloat(dialogueBoxData.att.x).getDefault(0);
			if (dialogueBoxData.has.y) y += Std.parseFloat(dialogueBoxData.att.y).getDefault(0);
			visible = false;

			var textNode = dialogueBoxData.node.text;
			if (textNode == null)
				throw "The dialog box XML requires one text element.";
			text = new FlxTypeText(
				textNode.has.x ? Std.parseFloat(textNode.att.x).getDefault(0) : 0,
				FlxG.height - (textNode.has.y ? Std.parseFloat(textNode.att.y).getDefault(0) : 0),
				textNode.has.width ? Std.parseInt(textNode.att.width).getDefault(FlxG.width) : FlxG.width, "");
			text.color = textNode.getAtt("color").getColorFromDynamic().getDefault(0xFF000000);
			text.size = Std.parseInt(textNode.att.size).getDefault(20);
			text.font = Paths.font('${textNode.getAtt("font").getDefault("vcr.ttf")}');
			text.antialiasing = textNode.getAtt("antialiasing").getDefault("false") == "true";
			text.sounds = [FlxG.sound.load(textTypeSFX)];
		} catch(e) {
			active = false;
			Logs.trace('Couldn\'t load dialogue box "$name": ${e.toString()}', ERROR);
		}
		FlxG.sound.cache(nextSFX);
		FlxG.sound.cache(textTypeSFX);
	}

	public function popupChar(char:DialogueCharacter) {
		if (!active) return;
		var pos = positions[char.positionName];
		if (pos == null) return;

		char.show((FlxG.width / 2) + pos.x, FlxG.height - pos.y);
	}

	private var __nextText:String;
	private var __speed:Float;
	public function playBubbleAnim(bubble:String, text:String, speed:Float = 0.05) {
		this.__nextText = text;
		this.__speed = speed;
		this.text.resetText(text);
		FlxG.sound.play(nextSFX);
		if (hasAnimation('$bubble-open'))
			playAnim('$bubble-open', true);
		else {
			playAnim(bubble);
			setText(__nextText, __speed);
		}
		visible = true;
	}

	public function setText(text:String, speed:Float = 0.02) {
		this.text.delay = speed;
		this.text.start(speed, true);
	}

	public override function update(elapsed:Float) {
		super.update(elapsed);
		if (isAnimFinished()) {
			var animName = getAnimName();
			if (animName.endsWith("-open")) {
				playAnim(animName.substr(0, animName.length - 5));
				setText(__nextText, __speed);
			}
		}
	}

	public override function destroy() {
		super.destroy();
		positions = null;
	}
}

typedef CharPosDef = {
	var x:Float;
	var y:Float;
	var flipBubble:Bool;
}