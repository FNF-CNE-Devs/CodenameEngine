package funkin.system;

import funkin.interfaces.IBeatReceiver;
import funkin.system.Conductor.BPMChangeEvent;
import funkin.system.Conductor;
import flixel.FlxG;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.ui.FlxUIState;
import flixel.math.FlxRect;
import flixel.math.FlxMath;
import flixel.util.FlxTimer;
import funkin.options.PlayerSettings;

class MusicBeatState extends FlxUIState implements IBeatReceiver
{
	private var lastBeat:Float = 0;
	private var lastStep:Float = 0;

	/**
	 * Whenever the Conductor auto update should be enabled or not.
	 */
	 public var cancelConductorUpdate:Bool = false;

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

	override function create()
	{
		super.create();
	}

	override function update(elapsed:Float)
	{
		//everyStep();
		var oldStep:Int = curStep;


		super.update(elapsed);
	}

	@:dox(hide) public function stepHit(curStep:Int):Void
	{
		for(e in members) if (e is IBeatReceiver) cast(e, IBeatReceiver).stepHit(curStep);
	}

	@:dox(hide) public function beatHit(curBeat:Int):Void
	{
		for(e in members) if (e is IBeatReceiver) cast(e, IBeatReceiver).beatHit(curBeat);
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
