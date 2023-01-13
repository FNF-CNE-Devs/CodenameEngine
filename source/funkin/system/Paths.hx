package funkin.system;

import flixel.graphics.frames.FlxFramesCollection;
import haxe.io.Path;
import funkin.mods.LimeLibrarySymbol;
import flixel.FlxG;
import flixel.graphics.frames.FlxAtlasFrames;
import openfl.utils.AssetType;
import openfl.utils.Assets as OpenFlAssets;
import funkin.mods.ModsFolder;
import funkin.scripting.Script;

using StringTools;

class Paths
{
	/**
	 * Preferred sound extension for the game's audio files.
	 * Currently is set to `mp3` for web targets, and `ogg` for other targets.
	 */
	inline public static var SOUND_EXT = #if web "mp3" #else "ogg" #end;

	public static var assetsTree:AssetsLibraryList;

	public static var tempFramesCache:Map<String, FlxFramesCollection> = [];

	public static function init() {
		FlxG.signals.preStateSwitch.add(function() {
			tempFramesCache.clear();
		});
	}

	public static function getPath(file:String, type:AssetType, library:Null<String>, skipModsVerification:Bool = false)
	{
		if (library != null)
			return getLibraryPath(file, library);

		return skipModsVerification ? 'assets:${getAssetsPath(file)}' : getAssetsPath(file);
	}

	static public function video(key:String) {
		return getPath('videos/$key.mp4', BINARY, null);
	}

	static public function getLibraryPath(file:String, library = "default")
	{
		return if (library == "preload" || library == "default") getAssetsPath(file); else getLibraryPathForce(file, library);
	}

	inline static function getLibraryPathForce(file:String, library:String)
	{
		if (library.startsWith("mods")) library = library.toLowerCase();
		return '$library:assets/$library/$file';
	}

	inline static function getAssetsPath(file:String)
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

	inline static public function ini(key:String, ?library:String)
	{
		return getPath('data/$key.ini', TEXT, library);
	}

	inline static public function fragShader(key:String, ?library:String)
	{
		return getPath('shaders/$key.frag', TEXT, library);
	}

	inline static public function vertShader(key:String, ?library:String)
	{
		return getPath('shaders/$key.vert', TEXT, library);
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

	inline static public function voices(song:String, difficulty:String = "normal")
	{
		var diff = getPath('songs/${song.toLowerCase()}/song/Voices-$difficulty.$SOUND_EXT', MUSIC, null);
		return OpenFlAssets.exists(diff) ? diff : getPath('songs/${song.toLowerCase()}/song/Voices.$SOUND_EXT', MUSIC, null);
	}

	inline static public function inst(song:String, difficulty:String = "normal")
	{
		var diff = getPath('songs/${song.toLowerCase()}/song/Inst-$difficulty.$SOUND_EXT', MUSIC, null);
		return OpenFlAssets.exists(diff) ? diff : getPath('songs/${song.toLowerCase()}/song/Inst.$SOUND_EXT', MUSIC, null);
	}

	inline static public function image(key:String, ?library:String, checkForAtlas:Bool = false)
	{
		var atlasPath = checkForAtlas ? getPath('images/$key/spritemap.png', IMAGE, library) : null;
		var multiplePath = checkForAtlas ? getPath('images/$key/1.png', IMAGE, library) : null;
		if (atlasPath != null && OpenFlAssets.exists(atlasPath)) return atlasPath.substr(0, atlasPath.length - 14);
		if (multiplePath != null && OpenFlAssets.exists(multiplePath)) return multiplePath.substr(0, multiplePath.length - 6);
		return getPath('images/$key.png', IMAGE, library);
	}

	inline static public function script(key:String, ?library:String, isAssetsPath:Bool = false) {
		var scriptPath = isAssetsPath ? key : getPath(key, TEXT, library);
		var p:String;
		for(ex in Script.scriptExtensions) {
			p = isAssetsPath ? '$key.$ex' : getPath('$key.$ex', TEXT, library);
			if (OpenFlAssets.exists(p)) {
				scriptPath = p;
				break;
			}
		}
		return scriptPath;
	}

	static public function chart(song:String, ?difficulty:String = "normal"):String {
		difficulty = difficulty.toLowerCase();
		song = song.toLowerCase();

		var difficultyEnd = (difficulty == "normal") ? "" : '-$difficulty';

		// songs/your-song/charts/hard.json
		var p = getPath('songs/$song/charts/$difficulty.json', TEXT, null);
		if (OpenFlAssets.exists(p)) return p;

		// data/charts/your-song/hard.json
		var p = json('charts/$song/$difficulty');
		if (OpenFlAssets.exists(p)) return p;

		return p; // returns the normal one so that it shows the correct path in the error message.
	}

	inline static public function font(key:String)
	{
		#if sys
		return sys.FileSystem.absolutePath(OpenFlAssets.getPath(getPath('fonts/$key', FONT, null)));
		#else
		return getPath('fonts/$key', FONT, null);
		#end
	}

	inline static public function obj(key:String) {
		return getPath('models/$key.obj', BINARY, null);
	}

	inline static public function dae(key:String) {
		return getPath('models/$key.dae', BINARY, null);
	}

	inline static public function md2(key:String) {
		return getPath('models/$key.md2', BINARY, null);
	}

	inline static public function md5(key:String) {
		return getPath('models/$key.md5', BINARY, null);
	}

	inline static public function awd(key:String) {
		return getPath('models/$key.awd', BINARY, null);
	}

	inline static public function getSparrowAtlas(key:String, ?library:String)
	{
		return FlxAtlasFrames.fromSparrow(image(key, library), file('images/$key.xml', library));
	}

	static public function getFrames(key:String, ?library:String) {
		if (tempFramesCache.exists(key)) {
			if (tempFramesCache[key].parent.bitmap.readable)
				return tempFramesCache[key];
			else
				tempFramesCache[key] = null;
		}
		return tempFramesCache[key] = CoolUtil.loadFrames(Paths.image(key, library, true));
	}
	inline static public function getSparrowAtlasAlt(key:String)
	{
		return FlxAtlasFrames.fromSparrow('$key.png', '$key.xml');
	}

	inline static public function getPackerAtlas(key:String, ?library:String)
	{
		return FlxAtlasFrames.fromSpriteSheetPacker(image(key, library), file('images/$key.txt', library));
	}

	inline static public function getPackerAtlasAlt(key:String)
	{
		return FlxAtlasFrames.fromSpriteSheetPacker('$key.png', '$key.txt');
	}

	static public function getFolderDirectories(key:String, addPath:Bool = false, source:funkin.system.AssetsLibraryList.AssetSource = BOTH):Array<String> {
		if (!key.endsWith("/")) key += "/";
		var content = assetsTree.getFolders('assets/$key', source);
		if (addPath) {
			for(k=>e in content)
				content[k] = '$key$e';
		}
		return content;
	}
	static public function getFolderContent(key:String, addPath:Bool = false, source:funkin.system.AssetsLibraryList.AssetSource = BOTH):Array<String> {
		// designed to work both on windows and web
		if (!key.endsWith("/")) key += "/";
		var content = assetsTree.getFiles('assets/$key', source);
		if (addPath) {
			for(k=>e in content)
				content[k] = '$key$e';
		}
		return content;
		/*
		if (!key.endsWith("/")) key = key + "/";

		if (ModsFolder.currentModFolder == null && !scanSource)
			return getFolderContent(key, false, addPath, true);

		var folderPath:String = scanSource ? getAssetsPath(key) : getLibraryPathForce(key, 'mods/${ModsFolder.currentModFolder}');
		var libThing = new LimeLibrarySymbol(folderPath);
		var library = libThing.library;

		if (library is openfl.utils.AssetLibrary) {
			var lib = cast(libThing.library, openfl.utils.AssetLibrary);
			@:privateAccess
			if (lib.__proxy != null) library = lib.__proxy;
		}
		
		var content:Array<String> = [];
		#if MOD_SUPPORT
		if (library is funkin.mods.ModsAssetLibrary) {
			// easy task, can immediately scan for files!
			var lib = cast(library, funkin.mods.ModsAssetLibrary);
			content = lib.getFiles(libThing.symbolName);
			if (addPath) 
				for(i in 0...content.length)
					content[i] = '$folderPath${content[i]}';
		} else #end {
			@:privateAccess
			for(k=>e in library.paths) {
				if (k.toLowerCase().startsWith(libThing.symbolName.toLowerCase())) {
					if (addPath) {
						if (libThing.libraryName != "")
							content.push('${libThing.libraryName}:$k');
						else
							content.push(k);
					} else {
						var barebonesFileName = k.substr(libThing.symbolName.length);
						if (!barebonesFileName.contains("/"))
							content.push(barebonesFileName);
					}
				}
			}
		}

		if (includeSource) {
			var sourceResult = getFolderContent(key, false, addPath, true);
			for(e in sourceResult)
				if (!content.contains(e))
					content.push(e);
		}

		return content;
		*/
	}
}
