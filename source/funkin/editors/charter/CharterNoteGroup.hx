package funkin.editors.charter;

import funkin.backend.system.Conductor;

class CharterNoteGroup extends FlxTypedGroup<CharterNote> {
	var __loopSprite:CharterNote;
	var i:Int = 0;
	var max:Float = 0;
	var __currentlyLooping:Bool = false;

	public override function forEach(noteFunc:CharterNote->Void, recursive:Bool = false) {
		__loopSprite = null;

		max = FlxG.height / 70 / camera.zoom;

		var oldCur = __currentlyLooping;
		__currentlyLooping = true;

		var curStep = Conductor.curStepFloat;
		if (FlxG.state is Charter && !FlxG.sound.music.playing)
			curStep = cast(FlxG.state, Charter).conductorFollowerSpr.y / 40;

		var begin = SortedArrayUtil.binarySearch(members, curStep - max, getVarForEachAdd);
		var end = SortedArrayUtil.binarySearch(members, curStep + max, getVarForEachRemove);

		for(i in begin...end) {
			__loopSprite = members[i];
			if (!cast(FlxG.state, Charter).selection.contains(__loopSprite))
				noteFunc(__loopSprite);
		}
		for(c in cast(FlxG.state, Charter).selection.copy())
			noteFunc(c);

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

	public override function draw() {
		@:privateAccess var oldDefaultCameras = FlxCamera._defaultCameras;
		@:privateAccess if (cameras != null) FlxCamera._defaultCameras = cameras;

		forEach((n) -> n.draw());

		@:privateAccess FlxCamera._defaultCameras = oldDefaultCameras;
	}

	public override function update(elapsed:Float) {
		@:privateAccess var oldDefaultCameras = FlxCamera._defaultCameras;
		@:privateAccess if (cameras != null) FlxCamera._defaultCameras = cameras;

		forEach((n) -> n.update(elapsed));

		@:privateAccess FlxCamera._defaultCameras = oldDefaultCameras;
	}
}