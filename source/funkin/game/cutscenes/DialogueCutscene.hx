package funkin.game.cutscenes;

import flixel.sound.FlxSound;
import funkin.game.cutscenes.dialogue.*;
import haxe.xml.Access;

/**
 * Substate made for dialogue cutscenes. To use it in a scripted cutscene, call `startDialogue`.
 */
class DialogueCutscene extends Cutscene {
	public var dialoguePath:String;
	public var dialogueData:Access;

	public var charMap:Map<String, DialogueCharacter> = [];

	public var dialogueLines:Array<DialogueLine> = [];
	public var curLine:DialogueLine = null;
	public var dialogueBox:DialogueBox;

	public var nextSFX:FlxSound;
	public var dialogueCamera:FlxCamera;

	public function new(dialoguePath:String, callback:Void->Void) {
		super(callback);
		this.dialoguePath = dialoguePath;
		camera = dialogueCamera = new FlxCamera();
		dialogueCamera.bgColor = 0;
		FlxG.cameras.add(dialogueCamera, false);
	}

	public override function create() {
		super.create();

		try {
			dialogueData = new Access(Xml.parse(Assets.getText(dialoguePath)).firstElement());

			// Add characters
			for(char in dialogueData.nodes.char) {
				if (!char.has.name) continue;
				if (charMap.exists(char.att.name))
					Logs.trace('2 dialogue characters share the same name (${char.att.name}, ${char.att.name}). The old character has been replaced.');
				add(charMap[char.att.name] = new DialogueCharacter(char.att.name, char.getAtt('position').getDefault('default')));
			}

			// Add lines
			for(node in dialogueData.nodes.line) {
				dialogueLines.push({
					text: XMLUtil.fixXMLText(node.innerHTML),
					char: node.getAtt('char').getDefault('boyfriend'),
					bubble: node.getAtt('bubble').getDefault('normal'),
					callback: node.getAtt('callback'),
					speed: node.has.speed ? Std.parseFloat(node.att.speed).getDefault(0.05) : 0.05
				});
			}

			// Add dialogue box
			dialogueBox = new DialogueBox(dialogueData.getAtt("box").getDefault("default"));
			add(dialogueBox);
			add(dialogueBox.text);
			

			next();
		} catch(e) {
			Logs.trace('Error while loading dialogue at ${dialoguePath}', ERROR);
			close();
		}
	}

	public override function update(elapsed:Float) {
		super.update(elapsed);
		if (controls.ACCEPT)
			next();
	}

	public function next() {
		if ((curLine = dialogueLines.shift()) == null) {
			close();
			return;
		}

		for(k=>c in charMap)
			if (k != curLine.char)
				c.hide();

		if (charMap[curLine.char] != null)
			dialogueBox.popupChar(charMap[curLine.char]);
		dialogueBox.playBubbleAnim(curLine.bubble, curLine.text, curLine.speed);
	}

	public override function destroy() {
		super.destroy();
		FlxG.cameras.remove(dialogueCamera);
	}
}

typedef DialogueLine = {
	var text:String;
	var char:String;
	var bubble:String;
	var callback:String;
	var speed:Float;
}