package funkin.utils;

import flixel.util.FlxTimer;
import flixel.tweens.FlxTween;

/**
 * Just add this in any substate to disable tweens, timers & camera movement from parent state.
 */
class FunkinParentDisabler extends FlxBasic {
	var __tweens:Array<FlxTween>;
	var __cameras:Array<FlxCamera>;
	var __timers:Array<FlxTimer>;
	var __replaceUponDestroy:Bool;
	public function new(replaceUponDestroy:Bool = true) {
		super();
		__replaceUponDestroy = replaceUponDestroy;
		@:privateAccess {
			// tweens
			__tweens = FlxTween.globalManager._tweens.copy();
			FlxTween.globalManager._tweens = [];

			// timers
			__timers = FlxTimer.globalManager._timers.copy();
			FlxTimer.globalManager._timers = [];

			// cameras
			__cameras = [for(c in FlxG.cameras.list) if (c.followActive) c];
			for(c in __cameras) c.followActive = false;
		}
	}

	public override function update(elapsed:Float) {}
	public override function draw() {}

	public override function destroy() {
		super.destroy();
		@:privateAccess {
			if (__replaceUponDestroy) {
				FlxTween.globalManager._tweens = __tweens;
				FlxTimer.globalManager._timers = __timers;
			} else {
				for(t in __tweens) FlxTween.globalManager._tweens.push(t);
				for(t in __timers) FlxTimer.globalManager._timers.push(t);
			}
			for(c in __cameras) c.followActive = true;
		}
	}
}