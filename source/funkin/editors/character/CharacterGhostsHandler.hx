package funkin.editors.character;

import haxe.xml.Access;
import flixel.math.FlxPoint;
import funkin.game.Character;

class CharacterGhostsHandler extends FlxTypedGroup<Character> {
	public var character:Character;
	public var animGhosts:Map<String, Character> = [];

	public function new(character:Character) {
		this.character = character;
		super();

		for (anim in character.getNameList())
			createGhost(anim);
	}

	public function createGhost(anim:String) {
		var ghost:Character = new Character(0,0, character.curCharacter);
		ghost.applyXML(character.xml); // apply cur character stuff
		ghost.playAnim(anim);
		ghost.stopAnimation();
		ghost.alpha = 0.5;
		ghost.visible = false;
		add(ghost);

		animGhosts.set(anim, ghost);
	}

	public function removeGhost(anim:String) {
		var ghost:Character = animGhosts.get(anim);
		@:privateAccess if (ghost != null) {
			ghost.animation._curAnim = null;
			animGhosts.remove(anim);
			ghost.destroy();
		}
	}

	public function updateInfos(xml:Xml) {
		for (anim => ghost in animGhosts) {
			ghost.applyXML(new Access(xml));
			ghost.playAnim(anim);
			ghost.stopAnimation();
		}

		rePositionGhosts();
	}

	public function updateOffsets(name:String, change:FlxPoint) {
		for (anim => ghost in animGhosts)
			ghost.animOffsets.set(name, ghost.getAnimOffset(name) + change);

		rePositionGhosts();
	}

	public function setOffsets(name:String, offset:FlxPoint) {
		for (anim => ghost in animGhosts)
			ghost.animOffsets.set(name, offset);

		rePositionGhosts();
	}

	public function clearOffsets() {
		for (anim => ghost in animGhosts)
			ghost.animOffsets[anim].zero();

		rePositionGhosts();
	}

	inline function rePositionGhosts() {
		for (ghost in animGhosts)
			ghost.frameOffset.set(ghost.getAnimOffset(ghost.getAnimName()).x, ghost.getAnimOffset(ghost.getAnimName()).y);
	}
}