package funkin.system;

import funkin.interfaces.IBeatReceiver;
import flixel.FlxG;
import funkin.system.Song.SwagSong;

/**
 * ...
 * @author
 */

typedef BPMChangeEvent =
{
	var stepTime:Int;
	var songTime:Float;
	var bpm:Float;
}

class Conductor
{
	/**
	 * Current BPM
	 */
	public static var bpm:Float = 100;

	/**
	 * Current Crochet (time per beat), in milliseconds.
	 */
	public static var crochet:Float = ((60 / bpm) * 1000); // beats in milliseconds
	
	/**
	 * Current StepCrochet (time per step), in milliseconds.
	 */
	public static var stepCrochet:Float = crochet / 4; // steps in milliseconds

	
	/**
	 * Current position of the song, in milliseconds.
	 */
	public static var songPosition:Float;

	
	/**
	 * Current step
	 */
	public static var curStep:Int = 0;
	
	 /**
	  * Current beat
	  */
	public static var curBeat:Int = 0;
 
	 
	 /**
	  * Current step, as a `Float` (ex: 4.94, instead of 4)
	  */
	public static var curStepFloat:Float = 0;
 
	 /**
	  * Current beat, as a `Float` (ex: 1.24, instead of 1)
	  */
	public static var curBeatFloat:Float = 0;

	
	@:dox(hide) public static var lastSongPos:Float;
	@:dox(hide) public static var offset:Float = 0;

	@:dox(hide) public static var safeZoneOffset:Float = 175; // is calculated in create(), is safeFrames in milliseconds

	/**
	 * Array of all BPM changes that have been mapped.
	 */
	public static var bpmChangeMap:Array<BPMChangeEvent> = [];

	@:dox(hide) public function new() {}

	public static function reset() {
		songPosition = lastSongPos = 0;
		bpmChangeMap = [];
		changeBPM(0);
	}
	/**
	 * Maps BPM changes from a song.
	 * @param song Song to map BPM changes from.
	 */
	public static function mapBPMChanges(song:SwagSong)
	{
		bpmChangeMap = [];

		var curBPM:Float = song.bpm;
		var totalSteps:Int = 0;
		var totalPos:Float = 0;
		for (i in 0...song.notes.length)
		{
			if(song.notes[i].changeBPM && song.notes[i].bpm != curBPM)
			{
				curBPM = song.notes[i].bpm;
				var event:BPMChangeEvent = {
					stepTime: totalSteps,
					songTime: totalPos,
					bpm: curBPM
				};
				bpmChangeMap.push(event);
			}

			var deltaSteps:Int = song.notes[i].lengthInSteps;
			totalSteps += deltaSteps;
			totalPos += ((60 / curBPM) * 1000 / 4) * deltaSteps;
		}
		trace("new BPM map BUDDY " + bpmChangeMap);
	}

	public static function init() {
		FlxG.signals.preUpdate.add(update);
		reset();
	}

	private static function update() {
		var elapsed = FlxG.elapsed;

		if (FlxG.sound.music == null || !FlxG.sound.music.playing) return;
		if (FlxG.state != null && FlxG.state is MusicBeatState && cast(FlxG.state, MusicBeatState).cancelConductorUpdate) return;
		if (lastSongPos != (lastSongPos = FlxG.sound.music.time)) {
			// update conductor
			songPosition = FlxG.sound.music.time;
		} else {
			songPosition += elapsed * 1000;
		}

		if (bpm > 0) {
			// updates curbeat and stuff
			var lastChange:BPMChangeEvent = {
				stepTime: 0,
				songTime: 0,
				bpm: 0
			}
			for (change in Conductor.bpmChangeMap)
			{
				if (Conductor.songPosition >= change.songTime)
					lastChange = change;
			}
	
			curStepFloat = lastChange.stepTime + ((Conductor.songPosition - lastChange.songTime) / Conductor.stepCrochet);
			curBeatFloat = curStepFloat / 4;

			if (curStep != (curStep = Std.int(curStepFloat))) {
				// updates step
				var updateBeat = curBeat != (curBeat = Std.int(curBeatFloat));

				if (FlxG.state is IBeatReceiver) {
					var state = FlxG.state;
					while(state != null) {
						if (FlxG.state is IBeatReceiver) {
							var st = cast(FlxG.state, IBeatReceiver);
							st.stepHit(curStep);
							if (updateBeat)
								st.beatHit(curBeat);
						}
						state = state.subState;
					}
				}
			}
		}
	}

	public static function changeBPM(newBpm:Float)
	{
		bpm = newBpm;

		crochet = ((60 / bpm) * 1000);
		stepCrochet = crochet / 4;
	}
}
