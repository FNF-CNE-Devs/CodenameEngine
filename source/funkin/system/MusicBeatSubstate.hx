package funkin.system;

import funkin.interfaces.IBeatReceiver;
import funkin.system.Conductor.BPMChangeEvent;
import funkin.system.Conductor;
import funkin.options.PlayerSettings;
import flixel.FlxG;
import flixel.FlxSubState;
import flixel.math.FlxMath;

class MusicBeatSubstate extends FlxSubState implements IBeatReceiver
{
	public function new()
	{
		super();
	}

	private var lastBeat:Float = 0;
	private var lastStep:Float = 0;

	
	/**
	 * Current step
	 */
	 public var curStep(get, never):Int;
	 /**
	  * Current beat
	  */
	 public var curBeat(get, never):Int;
	 /**
	  * Current step, as a `Float` (ex: 4.94, instead of 4)
	  */
	 public var curStepFloat(get, never):Float;
	 /**
	  * Current beat, as a `Float` (ex: 1.24, instead of 1)
	  */
	 public var curBeatFloat(get, never):Float;
	 /**
	  * Current song position (in milliseconds).
	  */
	 public var songPos(get, never):Float;
 
	 inline function get_curStep():Int
		 return Conductor.curStep;
	 inline function get_curBeat():Int
		 return Conductor.curBeat;
	 inline function get_curStepFloat():Float
		 return Conductor.curStepFloat;
	 inline function get_curBeatFloat():Float
		 return Conductor.curBeatFloat;
	 inline function get_songPos():Float
		 return Conductor.songPosition;
	 
	 /**
	  * Game Controls.
	  */
	public var controls(get, never):Controls;

	inline function get_controls():Controls
		return PlayerSettings.player1.controls;

	override function update(elapsed:Float)
	{
		super.update(elapsed);
	}


	@:dox(hide) public function stepHit(curStep:Int):Void
	{
		//do literally nothing neither dumbass
	}

	@:dox(hide) public function beatHit(curBeat:Int):Void
	{
		//do literally nothing dumbass
	}
	
	/**	
	 * Shortcut to `FlxMath.lerp` or `CoolUtil.lerp`, depending on `fpsSensitive`
	 * @param v1 Value 1
	 * @param v2 Value 2
	 * @param ratio Ratio
	 * @param fpsSensitive Whenever the ratio should not be adjusted to run at the same speed independant of framerate.
	 */
	public function lerp(v1:Float, v2:Float, ratio:Float, fpsSensitive:Bool = false) {
		if (fpsSensitive)
			return FlxMath.lerp(v1, v2, ratio);
		else
			return CoolUtil.fpsLerp(v1, v2, ratio);
	}
}
