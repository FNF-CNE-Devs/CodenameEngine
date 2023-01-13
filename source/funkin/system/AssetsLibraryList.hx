package funkin.system;

import funkin.mods.ModsAssetLibrary;
import openfl.utils.Assets;
import lime.utils.AssetLibrary;

class AssetsLibraryList extends AssetLibrary {
    public var libraries:Array<AssetLibrary> = [];
    public var base:AssetLibrary;

    public var sourceLibsAmount:Int = 0;

    public function removeLibrary(lib:AssetLibrary) {
        if (lib == null) return lib;
        libraries.remove(lib);
        return lib;
    }
    public function existsSpecific(id:String, type:String, source:AssetSource = BOTH) {
        if (!id.startsWith("assets/") && exists('assets/$id', type))
            return true;
        for(k=>e in libraries) {
            if (shouldSkipLib(k, source)) continue;
            if (e.exists(id, type))
                return true;
        }
        return false;
    }
    public override inline function exists(id:String, type:String):Bool
        return existsSpecific(id, type, BOTH);

    public function getSpecificPath(id:String, source:AssetSource = BOTH) {
        for(k=>e in libraries) {
            if (shouldSkipLib(k, source)) continue;

            @:privateAccess
            if (e.exists(id, e.types.get(id))) {
                var path = e.getPath(id);
                if (path != null)
                    return path;
            }
        }
        return null;
    }

    public override inline function getPath(id:String)
        return getSpecificPath(id, BOTH);

    public function getFiles(folder:String, source:AssetSource = BOTH):Array<String> {
        var content:Array<String> = [];
        for(k=>e in libraries) {
            if (shouldSkipLib(k, source)) continue;

            var l = e;

            if (l is openfl.utils.AssetLibrary) {
                @:privateAccess
                l = cast(l, openfl.utils.AssetLibrary).__proxy;
            }

            // TODO: do base folder scanning
            #if MOD_SUPPORT
            if (l is ModsAssetLibrary) {
                var lib = cast(l, ModsAssetLibrary);
                for(e in lib.getFiles(folder))
                    content.push(e);
            }
            #end
        }
        return content;
    }

    public function getFolders(folder:String, source:AssetSource = BOTH):Array<String> {
        var content:Array<String> = [];
        for(k=>e in libraries) {
            if (shouldSkipLib(k, source)) continue;

            var l = e;

            if (l is openfl.utils.AssetLibrary) {
                @:privateAccess
                l = cast(l, openfl.utils.AssetLibrary).__proxy;
            }

            // TODO: do base folder scanning
            #if MOD_SUPPORT
            if (l is ModsAssetLibrary) {
                var lib = cast(l, ModsAssetLibrary);
                for(e in lib.getFolders(folder))
                    content.push(e);
            }
            #end
        }
        return content;
    }

    public function getSpecificAsset(id:String, type:String, source:AssetSource = BOTH):Dynamic {
        try {
            MemoryUtil.disable();

            if (!id.startsWith("assets/")) {
                var ass = getSpecificAsset('assets/$id', type, source);
                if (ass != null) {
                    MemoryUtil.enable();
                    return ass;
                }
            }
            for(k=>e in libraries) {
                if (shouldSkipLib(k, source)) continue;

                var asset = e.getAsset(id, type);
                if (asset != null) {
                    MemoryUtil.enable();
                    return asset;
                }
            }

            MemoryUtil.enable();
            return null;
        } catch(e) {
            MemoryUtil.enable();
            throw e;
        }
        return null;
    }

    private function shouldSkipLib(k:Int, source:AssetSource) {
        return switch(source) {
            case BOTH:      false;
            case SOURCE:    k < libraries.length - sourceLibsAmount;
            case MODS:      k >= libraries.length - sourceLibsAmount;
        };
    }
    public override inline function getAsset(id:String, type:String):Dynamic
        return getSpecificAsset(id, type, BOTH);

    public function clearCache() {
        var libs:Array<AssetLibrary> = [for(lib in libraries) lib];
        libs.push(this);
        for(l in libs) {
            var lib:AssetLibrary = l;
            if (lib is openfl.utils.AssetLibrary) {
                var openflLib = cast(lib, openfl.utils.AssetLibrary);
                @:privateAccess
                if (openflLib.__proxy != null) lib = openflLib.__proxy;
            }

            @:privateAccess var cachedAudioBuffers = lib.cachedAudioBuffers;
            @:privateAccess var cachedBytes = lib.cachedBytes;
            @:privateAccess var cachedFonts = lib.cachedFonts;
            @:privateAccess var cachedImages = lib.cachedImages;
            @:privateAccess var cachedText = lib.cachedText;


            for(buff in cachedAudioBuffers) buff.dispose();
            cachedAudioBuffers.clear();

            cachedBytes.clear();
            cachedFonts.clear();
            cachedText.clear();
        }
    }

    public override function isLocal(id:String, type:String) {
        return true;
        // for(l in libraries) {
        //     var lib:AssetLibrary = l;
        //     if (lib is openfl.utils.AssetLibrary) {
        //         var openflLib = cast(lib, openfl.utils.AssetLibrary);
        //         @:privateAccess
        //         if (openflLib.__proxy != null) lib = openflLib.__proxy;
        //     }
        //     if (lib.exists(id, type) && lib.isLocal(id, type))
        //         return true;
        // }
        // return false;
    }

    public function new(?base:AssetLibrary) {
        super();
        if (base == null)
            base = Assets.getLibrary("default");
        addLibrary(this.base = base);
        sourceLibsAmount++;
    }

    public function addLibrary(lib:AssetLibrary) {
        libraries.insert(0, lib);
        return lib;
    }
}

enum abstract AssetSource(Null<Bool>) from Bool from Null<Bool> to Null<Bool> {
    var SOURCE = true;
    var MODS = false;
    var BOTH = null;
}