package funkin.backend.assets;

import lime.utils.Log;
import lime.utils.AssetLibrary;
import lime.utils.AssetManifest;

import haxe.io.Path;
import lime.app.Event;
import lime.app.Future;
import lime.app.Promise;
import lime.media.AudioBuffer;
import lime.graphics.Image;
import lime.text.Font;
import lime.utils.AssetType;
import lime.utils.Bytes;

#if MOD_SUPPORT
import sys.FileStat;
import sys.FileSystem;
#end

using StringTools;

interface IModsAssetLibrary {
	public var prefix:String;
	public var modName:String;
	public var libName:String;

	#if MOD_SUPPORT
	public var _parsedAsset:String;

	private function getAssetPath():String;

	private function __isCacheValid(cache:Map<String, Dynamic>, asset:String, isLocal:Bool = false):Bool;

	private function __parseAsset(asset:String):Bool;

	public function getFiles(folder:String):Array<String>;

	public function getFolders(folder:String):Array<String>;
	#end
}