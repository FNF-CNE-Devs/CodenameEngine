package funkin.game.cutscenes.dialogue;

import flixel.sound.FlxSound;
import flixel.addons.text.FlxTypeText;
import flixel.text.FlxText;
import flixel.math.FlxPoint;
import haxe.xml.Access;

class DialogueBox extends FunkinSprite {
	public var dialogueBoxData:Access;
	public var positions:Map<String, CharPosDef> = [];
	public var everPlayedAny:Bool = false;

	public var nextSFX:String = Paths.sound('dialogue/next');

	public var defaultTextTypeSFX:Array<FlxSound>;
	public var text:FlxTypeText;

	public function new(name:String) {
		super();
		var textTypeSFX:String = Paths.sound('dialogue/text');

		try {
			dialogueBoxData = new Access(Xml.parse(Assets.getText(Paths.xml('dialogue/boxes/$name'))).firstElement());
			if(!dialogueBoxData.has.sprite) dialogueBoxData.x.set("sprite", name);
			XMLUtil.loadSpriteFromXML(this, dialogueBoxData, "dialogue/boxes/", NONE);
			visible = false;

			var preX:Float = x;
			screenCenter(X); x += preX;
			y += FlxG.height - height;

			if(dialogueBoxData.has.textSound) textTypeSFX = Paths.sound(dialogueBoxData.att.textSound);
			if(dialogueBoxData.has.nextSound) nextSFX = Paths.sound(dialogueBoxData.att.nextSound);

			animation.finishCallback = (name:String) -> {
				var finalPt:String;
				if(name.endsWith(finalPt = "-open") || name.endsWith(finalPt = "-firstOpen")) {
					playAnim(name.substr(0, name.length - finalPt.length));
					setText(__nextText, __speed, __customTypeSFX);
				}
			}

			for(pos in dialogueBoxData.nodes.charpos) {
				if (!pos.has.name) continue;
				positions[pos.att.name] = {
					x: pos.has.x ? Std.parseFloat(pos.att.x).getDefault(0) : 0,
					y: pos.has.y ? Std.parseFloat(pos.att.y).getDefault(0) : 0,
					flipBubble: pos.getAtt('flipBubble') == "true"
				};
			}

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
			if(textNode.has.borderStyle) {
				text.borderStyle = switch(textNode.att.borderStyle.trim().toLowerCase()) {
					case "none": NONE;
					case "shadow": SHADOW;
					case "outline_fast": OUTLINE_FAST;
					default: OUTLINE;
				}
				text.borderSize = Std.parseFloat(textNode.getAtt("borderSize")).getDefault(1);
				text.borderColor = textNode.getAtt("borderColor").getColorFromDynamic().getDefault(0xFFFFFFFF);
			}
		} catch(e) {
			active = false;
			Logs.trace('Couldn\'t load dialogue box "$name": ${e.toString()}', ERROR);
		}
		defaultTextTypeSFX = [FlxG.sound.load(textTypeSFX)];
		FlxG.sound.cache(nextSFX);
	}

	public function popupChar(char:DialogueCharacter) {
		if (!active) return;
		var pos = positions[char.positionName];
		if (pos == null) return;

		char.show((FlxG.width / 2) + pos.x, FlxG.height - pos.y);
	}

	private var __nextText:String;
	private var __speed:Float;
	private var __customTypeSFX:Array<FlxSound>;
	public function playBubbleAnim(bubble:String, text:String, speed:Float = 0.05, ?customSFX:FlxSound, ?customTypeSFX:Array<FlxSound>, ?playNext:Bool) {
		this.__nextText = text;
		this.__speed = speed;
		this.__customTypeSFX = customTypeSFX;
		this.text.resetText(text);
		if(playNext || (playNext == null && everPlayedAny)) customSFX != null ? customSFX.play() : FlxG.sound.play(nextSFX);
		if(hasAnimation('$bubble-open')) playAnim('$bubble-open', true);
		else if(hasAnimation('$bubble-firstOpen') && !everPlayedAny) playAnim('$bubble-firstOpen', true);
		else {
			playAnim(bubble);
			setText(__nextText, __speed, __customTypeSFX);
		}
		visible = true;
		everPlayedAny = true;
	}

	public function setText(text:String, speed:Float = 0.02, ?customTypeSFX:Array<FlxSound>) {
		this.text.sounds = customTypeSFX != null ? customTypeSFX : defaultTextTypeSFX;
		this.text.delay = speed;
		this.text.start(speed, true);
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