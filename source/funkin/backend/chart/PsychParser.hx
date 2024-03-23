package funkin.backend.chart;

import funkin.backend.chart.ChartData.ChartEvent;
import funkin.backend.chart.FNFLegacyParser.SwagSong;
import funkin.backend.system.Conductor;

class PsychParser {
	public static function parse(data:Dynamic, result:ChartData)
		FNFLegacyParser.parse(data, result);

	public static function encode(chart:ChartData):Dynamic {
		var base:SwagSong = FNFLegacyParser.__convertToSwagSong(chart);
		base.notes = FNFLegacyParser.__convertToSwagSections(chart);
		base.stage = chart.stage;

		for (strumLine in chart.strumLines)
			if (strumLine.type == ADDITIONAL && base.gfVersion == null)
				base.gfVersion = strumLine.characters.getDefault(["gf"])[0];

		for (strumLine in chart.strumLines)
			for (note in strumLine.notes) {
				var section:Int = Math.floor(Conductor.getStepForTime(note.time) / Conductor.getMeasureLength());
				if (section > 0 && section < base.notes.length)
					base.notes[section].sectionNotes.push([
						note.time, // TIME
						note.id + (strumLine.type == PLAYER ? 3 : 0), // DATA
						note.sLen, // SUSTAIN LENGTH
						chart.noteTypes.getDefault([""])[note.type] // NOTE TYPE
					]);
			}

		base.events = [];

		var groupedEvents:Array<Array<ChartEvent>> = [];
		var __last:Array<ChartEvent> = null;
		var __lastTime:Float = Math.NaN;
		for (e in chart.events) {
			if (e == null) continue;
			if (__last != null && __lastTime == e.time)
				__last.push(e);
			else {
				__last = [e];
				__lastTime = e.time;
				groupedEvents.push(__last);
			}
		}

		for (events in groupedEvents) {
			var psychEvents:Array<Dynamic> = [];
			for (event in events)
				switch (event.name) {
					case "Add Camera Zoom":
						psychEvents.push([
							event.name,
							event.params[1] == "camGame" ? event.params[0] : 0, // CAMERA ZOOM
							event.params[1] == "camHUD" ? event.params[0] : 0, // UI ZOOM
						]);
					case "Play Animation":
						psychEvents.push([
							event.name,
							event.params[1], // ANIMATION TO PLAY
							switch (chart.strumLines[event.params[0]].type) { // CHARACTER
								case PLAYER: "bf";
								case OPPONENT: "dad";
								case ADDITIONAL: "gf";
							}
						]);
					case "Scroll Speed Change":
						var eventStep:Float = Conductor.getStepForTime(event.time);
						psychEvents.push([
							"Change Scroll Speed",
							event.params[1]/chart.scrollSpeed, // SCROLL SPEED MULTIPLER
							Conductor.getTimeForStep(eventStep+event.params[2]) - Conductor.getTimeForStep(eventStep), // TIME
						]);
					default:
						// TODO: allow custom formats in event.json
						var split:Float = event.params.length / 2;

						var val1:String = [for (arg in 0...Math.ceil(split)) event.params[arg]].join(",");
						var val2:String = [for (arg in Math.ceil(split)...event.params.length) event.params[arg]].join(",");

						psychEvents.push([event.name, val1, val2]);
				}
			base.events.push([events[0].time, psychEvents]);
		}

		return {song: base};
	}
}
