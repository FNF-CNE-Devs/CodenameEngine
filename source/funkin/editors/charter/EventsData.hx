package funkin.editors.charter;

import hscript.Parser;
import hscript.Interp;
import haxe.Json;
import sys.io.File;
import openfl.Assets;
import haxe.io.Path;
import funkin.backend.assets.Paths;

using StringTools;

class EventsData {
	public static var defaultEventsList:Array<String> = ["HScript Call", "Camera Movement", "BPM Change", "Alt Animation Toggle"];
	public static var defaultEventsParams:Map<String, Array<EventParamInfo>> = [
		"HScript Call" => [{name: "Function Name", type: TString, defValue: "myFunc"}, {name: "Function Parameters (String split with commas)", type: TString, defValue: ""}],
		"Camera Movement" => [{name: "Camera Target", type: TStrumLine, defValue: 0}],
		"BPM Change" => [{name: "Target BPM", type: TFloat(1), defValue: 100}],
		"Alt Animation Toggle" => [{name: "Strumline", type: TStrumLine, defValue: 0}, {name: "Enable", type: TBool, defValue: true}],
	];

	public static var eventsList:Array<String> = defaultEventsList.copy();
	public static var eventsParams:Map<String, Array<EventParamInfo>> = defaultEventsParams.copy();

	public static function getEventParams(name:String):Array<EventParamInfo> {
		return eventsParams.exists(name) ? eventsParams.get(name) : [];
	}

	public static function reloadEvents() {
		eventsList = defaultEventsList.copy();
		eventsParams = defaultEventsParams.copy();

		var hscriptInterp:Interp = new Interp();
		hscriptInterp.variables.set("Bool", TBool);
		hscriptInterp.variables.set("Int", function (?min:Int, ?max:Int, ?step:Float):EventParamType {return TInt(min, max, step);});
		hscriptInterp.variables.set("Float", function (?min:Int, ?max:Int, ?step:Float, ?precision:Int):EventParamType {return TFloat(min, max, step, precision);});
		hscriptInterp.variables.set("String", TString);
		hscriptInterp.variables.set("StrumLine", TStrumLine);

		var hscriptParser:Parser = new Parser();
		hscriptParser.allowJSON = hscriptParser.allowMetadata = false;

		for (file in Paths.getFolderContent('data/events/', true, BOTH)) {
			if (Path.extension(file) != "json") continue;
			var eventName:String = Path.withoutExtension(Path.withoutDirectory(file));

			eventsList.push(eventName);
			eventsParams.set(eventName, []);

			var fileTxt:String = Assets.getText(file);
			if (fileTxt.trim() == "") {continue;}

			try {
				var data:Dynamic = Json.parse(fileTxt);
				if (data == null || data.params == null) continue;
				
				var finalParams:Array<EventParamInfo> = [];
				for (paramData in cast(data.params, Array<Dynamic>)) {
					try {
						finalParams.push({name: paramData.name, type: hscriptInterp.expr(hscriptParser.parseString(paramData.type)), defValue: paramData.defaultValue});
					} catch (e) {trace('Error parsing event param ${paramData.name} - ${eventName}: $e');}
				}
				eventsParams.set(eventName, finalParams);
			} catch (e) {trace('Error parsing file $file: $e');}
		}

		hscriptInterp = null; hscriptParser = null;
	}
}

typedef EventInfo = {
	var params:Array<EventParamInfo>;
	var paramValues:Array<Dynamic>;
}

typedef EventParamInfo = {
	var name:String;
	var type:EventParamType;
	var defValue:Dynamic;
}

enum EventParamType {
	TBool;
	TInt(?min:Int, ?max:Int, ?step:Float);
	TFloat(?min:Int, ?max:Int, ?step:Float, ?precision:Int);
	TString;
	TStrumLine;
}