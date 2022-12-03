package funkin.system;

import funkin.mods.ModsAssetLibrary;
import openfl.utils.Assets;
import lime.utils.AssetLibrary;

class AssetsLibraryList extends AssetLibrary {
    public var libraries:Array<AssetLibrary> = [];
    public var base:AssetLibrary;

    public function removeLibrary(lib:AssetLibrary) {
        if (lib == null) return lib;
        libraries.remove(lib);
        return lib;
    }
    public override function exists(id:String, type:String) {
        if (!id.startsWith("assets/") && exists('assets/$id', type))
            return true;
        for(e in libraries)
            if (e.exists(id, type))
                return true;
        return false;
    }

    public override function getPath(id:String) {
        for(e in libraries) {
            var path = e.getPath(id);
            if (path != null)
                return path;
        }
        return null;
    }

    public function getFiles(folder:String):Array<String> {
        var content:Array<String> = [];
        for(e in libraries) {
            var l = e;

            if (l is openfl.utils.AssetLibrary) {
                @:privateAccess
                l = cast(l, openfl.utils.AssetLibrary).__proxy;
            }

            // TODO: do base folder scanning
            if (l is ModsAssetLibrary) {
                var lib = cast(l, ModsAssetLibrary);
                for(e in lib.getFiles(folder))
                    content.push(e);
            }
        }
        return content;
    }

    public override function getAsset(id:String, type:String) {
        if (!id.startsWith("assets/")) {
            var ass = getAsset('assets/$id', type);
            if (ass != null)
                return ass;
        }
        for(e in libraries) {
            var asset = e.getAsset(id, type);
            if (asset != null)
                return asset;
        }
        return null;
    }

    public function new(?base:AssetLibrary) {
        super();
        if (base == null)
            base = Assets.getLibrary("default");
        addLibrary(this.base = base);
    }

    public function addLibrary(lib:AssetLibrary) {
        libraries.insert(0, lib);
        return lib;
    }
}