package funkin.system;

import Section.SwagSection;
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

	var player1:String;
	var player2:String;
	var gf:String;
	var validScore:Bool;
}

class Song
{
	public static function loadFromJson(songName:String, ?difficulty:String = "normal"):SwagSong
	{
		var assetPath = Paths.chart(songName, difficulty);
		PlayState.fromMods = assetPath.startsWith("mods");
		var rawJson = Assets.getText(assetPath).trim();

		while (!rawJson.endsWith("}"))
		{
			rawJson = rawJson.substr(0, rawJson.length - 1);
			// LOL GOING THROUGH THE BULLSHIT TO CLEAN IDK WHATS STRANGE
		}

		return parseJSONshit(rawJson);
	}

	public static function parseJSONshit(rawJson:String):SwagSong
	{
		var swagShit:SwagSong = cast Json.parse(rawJson).song;
		swagShit.validScore = true;
		return swagShit;
	}
}
