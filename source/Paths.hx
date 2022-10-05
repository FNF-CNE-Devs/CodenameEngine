package;

import flixel.FlxG;
import flixel.graphics.frames.FlxAtlasFrames;
import openfl.utils.AssetType;
import openfl.utils.Assets as OpenFlAssets;
import funkin.mods.ModsFolder;

using StringTools;

class Paths
{
	/**
	 * Preferred sound extension for the game's audio files.
	 * Currently is set to `mp3` for web targets, and `ogg` for other targets.
	 */
	inline public static var SOUND_EXT = #if web "mp3" #else "ogg" #end;

	static var currentLevel:String;

	static public function setCurrentLevel(name:String)
	{
		currentLevel = name.toLowerCase();
	}

	static function getPath(file:String, type:AssetType, library:Null<String>, skipModsVerification:Bool = false)
	{
		if (library != null && library.startsWith("mods/")) {
			file = file.toLowerCase();
			library = library.toLowerCase();
		} else if (!skipModsVerification && ModsFolder.currentModFolder != null) {
			var modPath = getPath(file, type, 'mods/${ModsFolder.currentModFolder}');
			if (OpenFlAssets.exists(modPath)) return modPath;
		}

		if (library != null)
			return getLibraryPath(file, library);

		if (currentLevel != null)
		{
			var levelPath = getLibraryPathForce(file, currentLevel);
			if (OpenFlAssets.exists(levelPath, type))
				return levelPath;

			levelPath = getLibraryPathForce(file, "shared");
			if (OpenFlAssets.exists(levelPath, type))
				return levelPath;
		}

		return getPreloadPath(file);
	}

	static public function getLibraryPath(file:String, library = "preload")
	{
		return if (library == "preload" || library == "default") getPreloadPath(file); else getLibraryPathForce(file, library);
	}

	inline static function getLibraryPathForce(file:String, library:String)
	{
		return '$library:assets/$library/$file';
	}

	inline static function getPreloadPath(file:String)
	{
		return 'assets/$file';
	}

	inline static public function file(file:String, type:AssetType = TEXT, ?library:String)
	{
		return getPath(file, type, library);
	}

	inline static public function txt(key:String, ?library:String)
	{
		return getPath('data/$key.txt', TEXT, library);
	}

	inline static public function xml(key:String, ?library:String)
	{
		return getPath('data/$key.xml', TEXT, library);
	}

	inline static public function json(key:String, ?library:String)
	{
		return getPath('data/$key.json', TEXT, library);
	}

	static public function sound(key:String, ?library:String)
	{
		return getPath('sounds/$key.$SOUND_EXT', SOUND, library);
	}

	inline static public function soundRandom(key:String, min:Int, max:Int, ?library:String)
	{
		return sound(key + FlxG.random.int(min, max), library);
	}

	inline static public function music(key:String, ?library:String)
	{
		return getPath('music/$key.$SOUND_EXT', MUSIC, library);
	}

	inline static public function voices(song:String)
	{
		return getPath('songs/${song.toLowerCase()}/Voices.ogg', MUSIC, null);
	}

	inline static public function inst(song:String)
	{
		return getPath('songs/${song.toLowerCase()}/Inst.ogg', MUSIC, null);
	}

	inline static public function image(key:String, ?library:String)
	{
		return getPath('images/$key.png', IMAGE, library);
	}

	static public function chart(song:String, ?difficulty:String = "normal"):String {
		difficulty = difficulty.toLowerCase();
		song = song.toLowerCase();

		var difficultyEnd = (difficulty == "normal") ? "" : '-$difficulty';

		// charts/your-song/hard.json
		var p = getPath('charts/$song/$difficulty.json', TEXT, null);
		if (OpenFlAssets.exists(p)) return p;

		// charts/your-song/your-song-hard.json
		var p2 = getPath('charts/$song/$song$difficultyEnd.json', TEXT, null);
		if (OpenFlAssets.exists(p2)) return p2;

		// data/your-song/your-song-hard.json (default old format)
		p2 = json('$song/$song$difficultyEnd');
		if (OpenFlAssets.exists(p2)) return p2;

		return p; // returns the normal one so that it shows the correct path in the error message.
	}

	inline static public function font(key:String)
	{
		return 'assets/fonts/$key';
	}

	inline static public function getSparrowAtlas(key:String, ?library:String)
	{
		return FlxAtlasFrames.fromSparrow(image(key, library), file('images/$key.xml', library));
	}

	inline static public function getPackerAtlas(key:String, ?library:String)
	{
		return FlxAtlasFrames.fromSpriteSheetPacker(image(key, library), file('images/$key.txt', library));
	}

	inline static public function getFolderContent(key:String, includeSource:Bool = false, ?library:String):Array<String> {
		// designed to work both on windows and web
		
		while(key.charAt(key.length-1) == "/") key.substr(0, key.length-1);
		var path = getPath('$key/.foldercontent', TEXT, library);
		var content:Array<String> = [];
		if (OpenFlAssets.exists(path)) {
			var text = OpenFlAssets.getText(path);
			for(e in text.split("\n")) content.push(e.trim());
		}
		if (includeSource) {
			var path = getPath('$key/.foldercontent', TEXT, library, true);
			if (OpenFlAssets.exists(path)) {
				var text = OpenFlAssets.getText(path);
				for(e in text.split("\n")) content.push(e.trim());
			}
		}
		return content;
	}
}
