package funkin.backend.assets;

import funkin.backend.system.MainState;
import funkin.menus.TitleState;
import funkin.backend.system.Main;
import openfl.utils.AssetCache;
import flixel.util.FlxSignal.FlxTypedSignal;
import openfl.utils.AssetManifest;
import openfl.utils.AssetLibrary;
import flixel.graphics.FlxGraphic;
import flixel.util.FlxSignal.FlxTypedSignal;

import lime.text.Font;
import openfl.text.Font as OpenFLFont;

#if MOD_SUPPORT
import sys.FileSystem;
#end

import flixel.FlxState;
import haxe.io.Path;

using StringTools;

class ModsFolder {
	/**
	 * INTERNAL - Only use when editing source mods!!
	 */
	@:dox(hide) public static var onModSwitch:FlxTypedSignal<String->Void> = new FlxTypedSignal<String->Void>();

	/**
	 * Current mod folder. Will affect `Paths`.
	 */
	public static var currentModFolder:String = null;
	/**
	 * Path to the `mods` folder.
	 */
	public static var modsPath:String = "./mods/";
	/**
	 * Path to the `addons` folder.
	 */
	public static var addonsPath:String = "./addons/";

	/**
	 * Whenever its the first time mods has been reloaded.
	 */
	private static var __firstTime:Bool = true;
	/**
	 * Initialises `mods` folder by adding callbacks and such.
	 */
	public static function init() {

	}

	/**
	 * Switches mod - unloads all the other mods, then load this one.
	 * @param libName
	 */
	public static function switchMod(mod:String) {
		Options.lastLoadedMod = currentModFolder = mod;
		reloadMods();
	}

	public static function reloadMods() {
		if (!__firstTime)
			FlxG.switchState(new MainState());
		__firstTime = false;
	}

	/**
	 * Loads a mod library from the specified path. Supports folders and zips.
	 * @param modName Name of the mod
	 * @param force Whenever the mod should be reloaded if it has already been loaded
	 */
	public static function loadModLib(path:String, force:Bool = false) {
		#if MOD_SUPPORT
		if (FileSystem.exists('$path.zip'))
			return loadLibraryFromZip('$path'.toLowerCase(), '$path.zip', force);
		else
			return loadLibraryFromFolder('$path'.toLowerCase(), '$path', force);

		#else
		return null;
		#end
	}

	public static function prepareLibrary(libName:String, force:Bool = false) {
		var assets:AssetManifest = new AssetManifest();
		assets.name = libName;
		assets.version = 2;
		assets.libraryArgs = [];
		assets.assets = [];

		return AssetLibrary.fromManifest(assets);
	}

	public static function registerFont(font:Font) {
		var openflFont = new OpenFLFont();
		@:privateAccess
		openflFont.__fromLimeFont(font);
		OpenFLFont.registerFont(openflFont);
		return font;
	}

	public static function prepareModLibrary(libName:String, lib:IModsAssetLibrary, force:Bool = false) {
		var openLib = prepareLibrary(libName, force);
		lib.prefix = 'assets/';
		@:privateAccess
		openLib.__proxy = cast(lib, lime.utils.AssetLibrary);
		return openLib;
	}

	#if MOD_SUPPORT
	public static function loadLibraryFromFolder(libName:String, folder:String, force:Bool = false) {
		return prepareModLibrary(libName, new ModsFolderLibrary(folder, libName), force);
	}

	public static function loadLibraryFromZip(libName:String, zipPath:String, force:Bool = false) {
		return prepareModLibrary(libName, new ZipFolderLibrary(zipPath, libName), force);
	}
	#end
}