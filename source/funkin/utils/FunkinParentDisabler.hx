package funkin.utils;

import flixel.system.FlxSound;
import flixel.util.FlxTimer;
import flixel.tweens.FlxTween;

/**
 * FlxBasic allowing you to disable those elements from the parent state while this substate is opened
 * - Tweens
 * - Camera Movement
 * - Timers
 * - Sounds
 *
 * To use, add `add(new FunkinParentDisabler());` after `super.create();` in your `create` function.
 */
class FunkinParentDisabler extends FlxBasic {
	var __tweens:Array<FlxTween>;
	var __cameras:Array<FlxCamera>;
	var __timers:Array<FlxTimer>;
	var __sounds:Array<FlxSound>;
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

			// sounds
			__sounds = [for(s in FlxG.sound.list) if (s.playing) s];
			for(s in __sounds) s.pause();
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
			for(s in __sounds) s.play();
		}
	}
}