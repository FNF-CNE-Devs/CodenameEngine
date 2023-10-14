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
import lime.utils.Assets as LimeAssets;
import openfl.text.Font as OpenFLFont;


#if MOD_SUPPORT
import sys.FileStat;
import sys.FileSystem;
import sys.io.File;
import haxe.zip.Reader;
import funkin.backend.utils.SysZip;
import funkin.backend.utils.SysZip.SysZipEntry;

class ZipFolderLibrary extends AssetLibrary implements IModsAssetLibrary {
	public var zipPath:String;
	public var modName:String;
	public var libName:String;
	public var useImageCache:Bool = false;
	public var prefix = 'assets/';

	public var zip:SysZip;
	public var assets:Map<String, SysZipEntry> = [];

	public function new(zipPath:String, libName:String, ?modName:String) {
		this.zipPath = zipPath;
		this.libName = libName;

		if(modName == null)
			this.modName = libName;
		else
			this.modName = modName;

		zip = SysZip.openFromFile(zipPath);
		zip.read();
		for(entry in zip.entries)
			assets[entry.fileName.toLowerCase()] = entry;

		super();
	}

	public var _parsedAsset:String;

	public override function getAudioBuffer(id:String):AudioBuffer {
		__parseAsset(id);
		return AudioBuffer.fromBytes(unzip(assets[_parsedAsset]));
	}
	public override function getBytes(id:String):Bytes {
		__parseAsset(id);
		return Bytes.fromBytes(unzip(assets[_parsedAsset]));
	}
	public override function getFont(id:String):Font {
		__parseAsset(id);
		return ModsFolder.registerFont(Font.fromBytes(unzip(assets[_parsedAsset])));
	}
	public override function getImage(id:String):Image {
		__parseAsset(id);
		return Image.fromBytes(unzip(assets[_parsedAsset]));
	}

	public override function getPath(id:String):String {
		if (!__parseAsset(id)) return null;
		return getAssetPath();
	}



	public inline function unzip(f:SysZipEntry)
		return f == null ? null : zip.unzipEntry(f);

	public function __parseAsset(asset:String):Bool {
		if (!asset.startsWith(prefix)) return false;
		_parsedAsset = asset.substr(prefix.length);
		if(ModsFolder.useLibFile) {
			var file = new haxe.io.Path(_parsedAsset);
			if(file.file.startsWith("LIB_")) {
				var library = file.file.substr(4);
				if(library != modName) return false;

				_parsedAsset = file.dir + "." + file.ext;
			}
		}

		_parsedAsset = _parsedAsset.toLowerCase();
		return true;
	}

	public function __isCacheValid(cache:Map<String, Dynamic>, asset:String, isLocal:Bool = false) {
		if (cache.exists(isLocal ? '$libName:$asset': asset)) return true;
		return false;
	}

	public override function exists(asset:String, type:String):Bool {
		if(!__parseAsset(asset)) return false;

		return assets[_parsedAsset] != null;
	}

	private function getAssetPath() {
		trace('[ZIP]$zipPath/$_parsedAsset');
		return '[ZIP]$zipPath/$_parsedAsset';
	}

	public function getFiles(folder:String):Array<String> {
		var content:Array<String> = [];

		if (!folder.endsWith("/")) folder = folder + "/";
		if (!__parseAsset(folder)) return [];

		@:privateAccess
		for(k=>e in assets) {
			if (k.toLowerCase().startsWith(_parsedAsset)) {
				var fileName = k.substr(_parsedAsset.length);
				if (!fileName.contains("/"))
					content.push(fileName);
			}
		}
		return content;
	}

	public function getFolders(folder:String):Array<String> {
		var content:Array<String> = [];

		if (!folder.endsWith("/")) folder = folder + "/";
		if (!__parseAsset(folder)) return [];

		@:privateAccess
		for(k=>e in assets) {
			if (k.toLowerCase().startsWith(_parsedAsset)) {
				var fileName = k.substr(_parsedAsset.length);
				if (fileName.contains("/")) {
					var s = fileName.split("/")[0];
					if (!content.contains(s))
						content.push(s);
				}
			}
		}
		return content;
	}
}
#end