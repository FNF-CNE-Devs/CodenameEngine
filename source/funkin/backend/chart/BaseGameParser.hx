package funkin.backend.chart;

class BaseGameParser {
	public static function parse(data:Dynamic, result:ChartData) {
		// base fnf chart parsing
		var data:SwagSong = data;
		if (Reflect.hasField(data, "song")) {
			var field:Dynamic = Reflect.field(data, "song");
			if (!(field is String))
				data = field;
		}

		result.scrollSpeed = data.speed;
		result.stage = data.stage;

		var p2isGF:Bool = false;
		result.strumLines.push({
			characters: [data.player2],
			type: 0,
			position: (p2isGF = data.player2.startsWith("gf")) ? "girlfriend" : "dad",
			notes: []
		});
		result.strumLines.push({
			characters: [data.player1],
			type: 1,
			position: "boyfriend",
			notes: []
		});
		var gfName = data.gf != null ? data.gf : (data.gfVersion != null ? data.gfVersion : "gf");
		if (!p2isGF && gfName != "none") {
			result.strumLines.push({
				characters: [gfName],
				type: 2,
				position: "girlfriend",
				notes: [],
				visible: false,
			});
		}

		result.meta.bpm = data.bpm;
		result.meta.needsVoices = data.needsVoices.getDefault(true);

		var camFocusedBF:Bool = false;
		var altAnims:Bool = false;
		var beatsPerMeasure:Float = data.beatsPerMeasure.getDefault(4);
		var curBPM:Float = data.bpm;
		var curTime:Float = 0;
		var curCrochet:Float = ((60 / curBPM) * 1000);

		if (data.notes != null) for(section in data.notes) {
			if (section == null) {
				curTime += curCrochet * beatsPerMeasure;
				continue; // Yoshi Engine charts crash fix
			}

			if (camFocusedBF != (camFocusedBF = section.mustHitSection)) {
				result.events.push({
					time: curTime,
					name: "Camera Movement",
					params: [camFocusedBF ? 1 : 0]
				});
			}

			if (section.altAnim == null) section.altAnim = false;
			if (altAnims != (altAnims = section.altAnim)) {
				result.events.push({
					time: curTime,
					name: "Alt Animation Toggle",
					params: [altAnims, false, 0]
				});
			}

			if (section.sectionNotes != null) for(note in section.sectionNotes) {
				if (note[1] < 0) continue;

				var daStrumTime:Float = note[0];
				var daNoteData:Int = Std.int(note[1] % 8);
				var daNoteType:Int = Std.int(note[1] / 8);
				var gottaHitNote:Bool = daNoteData >= 4 ? !section.mustHitSection : section.mustHitSection;

				if (note.length > 2) {
					if (note[3] is Int && data.noteTypes != null)
						daNoteType = Chart.addNoteType(result, data.noteTypes[Std.int(note[3])-1]);
					else if (note[3] is String)
						daNoteType = Chart.addNoteType(result, note[3]);
				} else {
					if(data.noteTypes != null)
						daNoteType = Chart.addNoteType(result, data.noteTypes[daNoteType-1]);
				}

				result.strumLines[gottaHitNote ? 1 : 0].notes.push({
					time: daStrumTime,
					id: daNoteData % 4,
					type: daNoteType,
					sLen: note[2]
				});
			}

			if (section.changeBPM && section.bpm != curBPM) {
				curCrochet = ((60 / (curBPM = section.bpm)) * 1000);

				result.events.push({
					time: curTime,
					name: "BPM Change",
					params: [section.bpm]
				});
			}

			curTime += curCrochet * beatsPerMeasure;
		}
	}
}
typedef SwagSong =
{
	var song:String;
	var notes:Array<SwagSection>;
	var bpm:Float;
	var needsVoices:Bool;
	var speed:Float;
	var stage:String;
	var noteTypes:Array<String>;

	var player1:String;
	var player2:String;
	var gf:String;
	var gfVersion:String;
	var validScore:Bool;

	// ADDITIONAL STUFF THAT MAY NOT BE PRESENT IN CHART
	var ?maxHealth:Float;
	var ?beatsPerMeasure:Float;
	var ?stepsPerBeat:Float;
}

typedef SwagSection =
{
	var sectionNotes:Array<Dynamic>;
	var lengthInSteps:Int;
	var mustHitSection:Bool;
	var bpm:Float;
	var changeBPM:Bool;
	var altAnim:Null<Bool>;
	@:optional var camTarget:Null<Float>;
}
