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

class MusicBeatState extends FlxUIState
{
	private var lastBeat:Float = 0;
	private var lastStep:Float = 0;

	private var curStep:Int = 0;
	private var curBeat:Int = 0;
	private var curStepFloat:Float = 0;
	private var curBeatFloat:Float = 0;
	private var controls(get, never):Controls;

	inline function get_controls():Controls
		return PlayerSettings.player1.controls;

	override function create()
	{
		if (transIn != null)
			trace('reg ' + transIn.region);

		super.create();
	}

	override function update(elapsed:Float)
	{
		//everyStep();
		var oldStep:Int = curStep;

		updateCurStep();
		updateBeat();

		if (oldStep != curStep && curStep > 0)
			stepHit();

		super.update(elapsed);
	}

	private function updateBeat():Void
	{
		curBeat = Math.floor(curBeatFloat = (curStepFloat / 4));
	}

	private function updateCurStep():Void
	{
		var lastChange:BPMChangeEvent = {
			stepTime: 0,
			songTime: 0,
			bpm: 0
		}
		for (i in 0...Conductor.bpmChangeMap.length)
		{
			if (Conductor.songPosition >= Conductor.bpmChangeMap[i].songTime)
				lastChange = Conductor.bpmChangeMap[i];
		}

		curStep = Math.floor(curStepFloat = lastChange.stepTime + ((Conductor.songPosition - lastChange.songTime) / Conductor.stepCrochet));
	}

	public function stepHit():Void
	{
		for(e in members) if (e is IBeatReceiver) cast(e, IBeatReceiver).stepHit(curStep);
		
		if (curStep % 4 == 0)
			beatHit();
	}

	public function beatHit():Void
	{
		for(e in members) if (e is IBeatReceiver) cast(e, IBeatReceiver).beatHit(curBeat);
	}

	public function lerp(v1:Float, v2:Float, ratio:Float, fpsSensitive:Bool = false) {
		if (fpsSensitive)
			return FlxMath.lerp(v1, v2, ratio);
		else
			return CoolUtil.fpsLerp(v1, v2, ratio);
	}
}
