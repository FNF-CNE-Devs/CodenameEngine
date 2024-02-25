package funkin.game.cutscenes.dialogue;

import funkin.backend.scripting.events.*;
import funkin.backend.scripting.events.PlayAnimEvent.PlayAnimContext;
import funkin.backend.scripting.events.CancellableEvent;
import funkin.backend.scripting.Script;
import flixel.sound.FlxSound;
import flixel.addons.text.FlxTypeText;
import flixel.text.FlxText;
import flixel.math.FlxPoint;
import haxe.xml.Access;

class DialogueBox extends FunkinSprite {
	public var dialogueBoxData:Access;
	public var positions:Map<String, CharPosDef> = [];
	public var dialogueEnded:Bool = false;  // Using text._typing is also fair but it doesnt check for eventual opening anims!  - Nex

	public var nextSFX:String = Paths.sound('dialogue/next');
	public var defaultTextTypeSFX:Array<FlxSound>;
	public var text:FlxTypeText;

	public var defPath:String = 'dialogue/boxes/';
	public var dialogueBoxScript:Script;
	public var cutscene:DialogueCutscene = DialogueCutscene.cutscene;

	public function new(name:String) {
		super();
		var textTypeSFX:String = Paths.sound('dialogue/text');  // Default if xml doesnt have it  - Nex

		dialogueBoxScript = Script.create(Paths.script('data/' + defPath + name));
		dialogueBoxScript.setParent(this);
		dialogueBoxScript.load();

		var event = EventManager.get(DialogueBoxStructureEvent).recycle(name, textTypeSFX, null);
		dialogueBoxScript.call('create', [event]);
		if(event.cancelled) return;  // No idea the pyscho that would do this but hey, it can happen  - Nex

		try {
			event.dialogueBoxData = dialogueBoxData = new Access(Xml.parse(Assets.getText(Paths.xml(defPath + event.name))).firstElement());
			dialogueBoxScript.call('structureLoaded', [event]);
			if(event.cancelled) return;
			name = event.name;
			textTypeSFX = event.textTypeSFX;
			dialogueBoxData = event.dialogueBoxData;

			if(!dialogueBoxData.has.sprite) dialogueBoxData.x.set("sprite", name);
			XMLUtil.loadSpriteFromXML(this, dialogueBoxData, defPath, NONE);
			visible = false;

			var preX:Float = x;
			screenCenter(X); x += preX;
			y += FlxG.height - height;

			if(dialogueBoxData.has.textSound) textTypeSFX = Paths.sound(dialogueBoxData.att.textSound);
			if(dialogueBoxData.has.nextSound) nextSFX = Paths.sound(dialogueBoxData.att.nextSound);

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
		dialogueBoxScript.call("postCreate");
	}

	public override function playAnim(AnimName:String, Force:Bool = false, Context:PlayAnimContext = NONE, Reversed:Bool = false, Frame:Int = 0) {
		var event = EventManager.get(PlayAnimEvent).recycle(AnimName, Force, Reversed, Frame, Context);
		dialogueBoxScript.call("onPlayAnim", [event]);
		if(event.cancelled) return;

		super.playAnim(event.animName, event.force, event.context, event.reverse, event.startingFrame);
	}

	public override function beatHit(curBeat:Int) {
		super.beatHit(curBeat);
		dialogueBoxScript.call("beatHit", [curBeat]);
	}

	public override function update(elapsed:Float) {
		super.update(elapsed);
		dialogueBoxScript.call("update", [elapsed]);
	}

	public function popupChar(char:DialogueCharacter, force:Bool = false) {
		var event = EventManager.get(DialogueBoxCharPopupEvent).recycle(char);
		dialogueBoxScript.call("popupChar", [event]);
		if (event.cancelled || event.char == null || !active) return;
		var pos = positions[event.char.positionName];
		if (pos == null) return;

		event.char.show((FlxG.width / 2) + pos.x, FlxG.height - pos.y, null, force);
	}

	public function playBubbleAnim(bubble:String, suffix:String = '', text:String = '', speed:Float = 0.05, ?customSFX:FlxSound, ?customTypeSFX:Array<FlxSound>, setTextAfter:Bool = false, allowDefault:Bool = true) {
		var event = EventManager.get(DialogueBoxPlayBubbleEvent).recycle(bubble, suffix, text, speed, customSFX, customTypeSFX, setTextAfter, allowDefault);
		dialogueBoxScript.call("playBubbleAnim", [event]);
		if(event.cancelled) return;

		if(event.customSFX != null) event.customSFX.play();
		else if(event.allowDefault) FlxG.sound.play(nextSFX);
		var idk:Void->Void = () -> {
			if(text != null && text.trim().length > 0) setText(event.text, event.speed, event.customTypeSFX);
			else dialogueEnded = true;
		}

		dialogueEnded = false;
		this.text.resetText('');
		var anim:String = event.bubble + event.suffix;
		if(hasAnimation(anim)) playAnim(anim, true);
		if(!event.setTextAfter) idk();
		else animation.finishCallback = (name:String) -> {
			if(name != anim) return;
			playAnim(event.bubble);
			idk(); animation.finishCallback = null;
		}

		visible = true;
		dialogueBoxScript.call("postPlayBubbleAnim", [event]);
	}

	public function setText(text:String, speed:Float = 0.05, ?customTypeSFX:Array<FlxSound>) {
		var event = EventManager.get(DialogueBoxSetTextEvent).recycle(text, speed, customTypeSFX);
		dialogueBoxScript.call("setText", [event]);
		if(event.cancelled) return;

		this.text.resetText(event.text);
		this.text.sounds = event.customTypeSFX != null ? event.customTypeSFX : defaultTextTypeSFX;
		this.text.delay = event.speed;
		this.text.start(event.speed, true);
		this.text.completeCallback = () -> dialogueEnded = true;
	}

	public override function destroy() {
		dialogueBoxScript.call("destroy");
		dialogueBoxScript.destroy();

		super.destroy();
		positions = null;
	}
}

typedef CharPosDef = {
	var x:Float;
	var y:Float;
	var flipBubble:Bool;
}