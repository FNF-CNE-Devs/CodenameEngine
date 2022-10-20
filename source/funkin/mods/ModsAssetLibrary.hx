package funkin.mods;

import lime.utils.Log;
import lime.utils.AssetLibrary;
import lime.utils.AssetManifest;

import haxe.io.Path;
import lime.app.Event;
import lime.app.Future;
import lime.app.Promise;
import lime.media.AudioBuffer;
import lime.graphics.Image;
import lime.net.HTTPRequest;
import lime.text.Font;
import lime.utils.AssetType;
import lime.utils.Bytes;

#if MOD_SUPPORT
import sys.FileStat;
import sys.FileSystem;
#end

using StringTools;

class ModsAssetLibrary extends AssetLibrary {
    public var folderPath:String;
    public var libName:String;
    public var useImageCache:Bool = false;

    public function new(folderPath:String, libName:String) {
        this.folderPath = folderPath;
        this.libName = libName;
        super();
    }

    #if MOD_SUPPORT
    private var editedTimes:Map<String, Float> = [];
    var _parsedAsset:String = null;

    public function getEditedTime(asset:String):Null<Float> {
        return editedTimes[asset];
    }

    public override function getAudioBuffer(id:String):AudioBuffer {
        if (__isCacheValid(cachedAudioBuffers, id))
            return cachedAudioBuffers.get(id);
        else {
            if (!exists(id, "SOUND")) {
                Log.error('ModsAssetLibrary: Audio Buffer at $id does not exist.');
                return null;
            }
            var path = getAssetPath();
            editedTimes[id] = FileSystem.stat(path).mtime.getTime();
            var e = AudioBuffer.fromFile(path);
            cachedAudioBuffers.set(id, e);
            return e;
        }
    }

    public override function getBytes(id:String):Bytes {
        if (__isCacheValid(cachedBytes, id))
            return cachedBytes.get(id);
        else {
            if (!exists(id, "BINARY")) {
                Log.error('ModsAssetLibrary: Bytes at $id does not exist.');
                return null;
            }
            var path = getAssetPath();
            editedTimes[id] = FileSystem.stat(path).mtime.getTime();
            var e = Bytes.fromFile(path);
            cachedBytes.set(id, e);
            return e;
        }
    }

    public override function getFont(id:String):Font {
        if (__isCacheValid(cachedFonts, id))
            return cachedFonts.get(id);
        else {
            if (!exists(id, "FONT")) {
                Log.error('ModsAssetLibrary: Font at $id does not exist.');
                return null;
            }
            var path = getAssetPath();
            editedTimes[id] = FileSystem.stat(path).mtime.getTime();
            var e = Font.fromFile(path);
            cachedFonts.set(id, e);
            return e;
        }
    }

    public override function getImage(id:String):Image {
        if (useImageCache && __isCacheValid(cachedImages, id))
            return cachedImages.get(id);
        else {
            if (!exists(id, "IMAGE")) {
                Log.error('ModsAssetLibrary: Image at $id does not exist.');
                return null;
            }
            var path = getAssetPath();
            editedTimes[id] = FileSystem.stat(path).mtime.getTime();

            var e = Image.fromFile(path);
            cachedImages.set(id, e);
            return e;
        }
    }

    public override function getPath(id:String):String {
        if (!__parseAsset(id)) return null;
        return getAssetPath();
    }

    public function getFiles(folder:String):Array<String> {
        if (!folder.endsWith("/")) folder = folder + "/";
        if (!__parseAsset(folder)) return [];
        var path = getAssetPath();
        try {
            var result:Array<String> = [];
            for(e in FileSystem.readDirectory(path))
                if (!FileSystem.isDirectory('$path$e'))
                    result.push(e);
            return result;
        } catch(e) {
            // woops!!
        }
        return [];
    }

    public override function exists(asset:String, type:String):Bool { 
        if(!__parseAsset(asset)) return false;

        return FileSystem.exists(getAssetPath());
    }

    private function getAssetPath() {
        return '$folderPath/$_parsedAsset';
    }

    private function __isCacheValid(cache:Map<String, Dynamic>, asset:String) {
        if (!editedTimes.exists(asset))
            return false;
        if (editedTimes[asset] == null) return false;
        if (editedTimes[asset] < FileSystem.stat(getPath(asset)).mtime.getTime()) return false;
        return cache.exists(asset) && cache[asset] != null;
    }

    private function __parseAsset(asset:String):Bool {
        var prefix = 'assets/$libName/';
        if (!asset.startsWith(prefix)) return false;
        _parsedAsset = asset.substr(prefix.length);
        return true;
    }
    #end
}