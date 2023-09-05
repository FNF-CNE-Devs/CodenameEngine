package funkin.editors.charter;

import flixel.util.FlxSort;
import funkin.backend.system.Conductor;

class CharterNoteGroup extends FlxTypedGroup<CharterNote> {
	var __loopSprite:CharterNote;
	var i:Int = 0;
	var max:Float = 0;
	var __currentlyLooping:Bool = false;
	var __lastSort:Int = 0;

	public override function forEach(noteFunc:CharterNote->Void, recursive:Bool = false) {
		__loopSprite = null;

		max = FlxG.height / 70 / camera.zoom;

		var oldCur = __currentlyLooping;
		__currentlyLooping = true;

		var curStep = Conductor.curStepFloat;
		if (!FlxG.sound.music.playing)
			curStep = Charter.instance.gridBackdrops.conductorSprY / 40;

		var begin = SortedArrayUtil.binarySearch(members, curStep - max, getVarForEachAdd);
		var end = SortedArrayUtil.binarySearch(members, curStep + max, getVarForEachRemove);

		for(i in begin...end) {
			__loopSprite = members[i];
			if (!Charter.instance.selection.contains(__loopSprite))
				noteFunc(__loopSprite);
		}
		for(c in Charter.instance.selection.copy())
			if (c is CharterNote) noteFunc(cast (c, CharterNote));

		__currentlyLooping = oldCur;
	}

	public override function add(v:CharterNote):CharterNote {
		SortedArrayUtil.addSorted(members, v, getVar);
		return v;
	}

	public override function remove(v:CharterNote, force:Bool = true):CharterNote
		return super.remove(v, true);

	private static function getVar(n:CharterNote)
		return n.step;

	private static function getVarForEachAdd(n:CharterNote)
		return n.step + n.susLength;
	private static function getVarForEachRemove(n:CharterNote)
		return n.step - n.susLength;

	public override function draw() {}

	public override function update(elapsed:Float) {
		@:privateAccess var oldDefaultCameras = FlxCamera._defaultCameras;
		@:privateAccess if (cameras != null) FlxCamera._defaultCameras = cameras;

		if (length != __lastSort)
			sortNotes();
		
		forEach((n) -> {
			if(n.exists && n.active)
				n.update(elapsed);
		});

		@:privateAccess FlxCamera._defaultCameras = oldDefaultCameras;
	}

	public function sortNotes() {
		__lastSort = length;
		this.sort(function(i, n1, n2) {
			if (n1.step == n2.step)
				return FlxSort.byValues(FlxSort.ASCENDING, n1.fullID, n2.fullID);
			return FlxSort.byValues(FlxSort.ASCENDING, n1.step, n2.step);
		});
	}
}