package funkin.system;

import funkin.system.Section.SwagSection;
import haxe.Json;
import haxe.format.JsonParser;
import lime.utils.Assets;

using StringTools;

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
	var validScore:Bool;

	// ADDITIONAL STUFF THAT MAY NOT BE PRESENT IN CHART
	var ?maxHealth:Float;
}

class Song
{
	public static function loadFromJson(songName:String, ?difficulty:String = "normal"):SwagSong
	{
		var assetPath = Paths.chart(songName, difficulty);
		PlayState.fromMods = Paths.assetsTree.existsSpecific(assetPath, "TEXT", MODS);
		var rawJson = Assets.getText(assetPath).trim();

		rawJson = rawJson.substr(0, rawJson.lastIndexOf('}') + 1);

		return parseJSONshit(rawJson);
	}

	public static function parseJSONshit(rawJson:String):SwagSong
	{
		var swagShit:SwagSong = cast Json.parse(rawJson).song;
		swagShit.validScore = true;
		return swagShit;
	}
}
