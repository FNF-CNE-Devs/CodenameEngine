package funkin.mods;

import flixel.util.FlxSignal.FlxTypedSignal;
import openfl.utils.Assets;
import openfl.utils.AssetManifest;
import openfl.utils.AssetLibrary;
import flixel.graphics.FlxGraphic;
import flixel.util.FlxSignal.FlxTypedSignal;

#if MOD_SUPPORT
import sys.FileSystem;
#end

import flixel.FlxG;
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
     * Array of all loaded mods' folder names.
     */
    public static var loadedMods:Array<String> = [];
    /**
     * Path to the `mods` folder.
     */
    public static var modsPath:String = "./mods/";

    /**
     * Initialises `mods` folder by adding callbacks and such.
     */
    public static function init() {
        FlxG.signals.preStateCreate.add(onStateSwitch);
    }

    /**
     * Loads a mod with the specified name.
     * @param modName Name of the mod
     * @param force Whenever the mod should be reloaded if it has already been loaded
     */
    public static function loadMod(mod:String, force:Bool = false) {
        #if MOD_SUPPORT
        if (mod == null) return null; // may be loading base game

        if (FileSystem.exists('${modsPath}$mod.zip')) {
            var e = loadLibraryFromZip('mods/$mod'.toLowerCase(), '${modsPath}$mod.zip', force);
            loadedMods.push(mod);
            return e;
        } else {
            var e = loadLibraryFromFolder('mods/$mod'.toLowerCase(), '${modsPath}$mod', force);
            loadedMods.push(mod);
            return e;
        }
        #else
        return null;
        #end
    }

    /**
     * Switches mod - unloads all the other mods, then load this one.
     * @param libName 
     */
    public static function switchMod(mod:String) {
        for(m in loadedMods)
            unloadMod(m);
        
        loadMod(ModsFolder.currentModFolder = mod);
        onModSwitch.dispatch(ModsFolder.currentModFolder);
        FlxG.resetState();
    }

    public static function unloadMod(mod:String) {
        Assets.unloadLibrary('mods/$mod'.toLowerCase());
    }

    public static function prepareLibrary(libName:String, force:Bool = false) {
        if (Assets.hasLibrary(libName)) {
            if (force)
                Assets.unloadLibrary(libName);
            else
                return null;
        }
        
        var assets:AssetManifest = new AssetManifest();
        assets.name = libName;
        assets.version = 2;
        assets.libraryArgs = [];
        assets.assets = [];

        return AssetLibrary.fromManifest(assets);
    }

    public static function loadLibraryFromZip(libName:String, zipPath:String, force:Bool = false) {
        var lib = prepareLibrary(libName, force);
        @:privateAccess
        lib.__proxy = new ZipFolderLibrary(zipPath, libName);
        Assets.registerLibrary(libName, lib);
        return lib;
    }

    public static function loadLibraryFromFolder(libName:String, folder:String, force:Bool = false) {
        var lib = prepareLibrary(libName, force);
        @:privateAccess
        lib.__proxy = new ModsFolderLibrary(folder, libName);
        Assets.registerLibrary(libName, lib);
        return lib;
    }

    /**
     * Gets all assets in folders and put them in the `assets` array.
     * @param assets Array of assets
     * @param rootPath Root path
     * @param path Path inside of the rootPath (ex: `root path/path/path2/`)
     * @param libraryName Name of the library (ex: `mods/my mod/`)
     * @param prefix Prefix for the asset names (ex: `assets/mods/my mod/`)
     * @param addRoot Whenever the root should be added to the paths. Defaults to false
     */
    public static function getAssetFiles(assets:Array<Dynamic>, rootPath:String, path:String, libraryName:String, prefix:String = "", addRoot:Bool = false) {
        #if sys
        for(f in FileSystem.readDirectory('$rootPath$path')) {
            if (FileSystem.isDirectory('$rootPath$path$f')) {
                // fuck you git
                if (f.toLowerCase() != ".git")
                    getAssetFiles(assets, rootPath, '$path$f/', libraryName);
            } else {
                var type = "BINARY";
                var useExt:Bool = true;
                switch(Path.extension(f).toLowerCase()) {
                    case "txt" | "xml" | "json" | "hx" | "hscript" | "hsc" | "lua" | "frag" | "vert":
                        type = "TEXT";
                    case "png":
                        type = "IMAGE";
                    case "ogg":
                        type = path.toLowerCase().startsWith("music") ? "MUSIC" : "SOUND";
                    case "ttf":
                        type = "FONT";
                        useExt = false;

                }
                var stat = FileSystem.stat('$rootPath$path$f');
                assets.push({
                    type: type,
                    id: ('assets/$libraryName/$prefix$path${useExt ? f : Path.withoutExtension(f)}').toLowerCase(), // for case sensitive shit & correct linux support
                    path: (addRoot ? rootPath : '') + '$path$f',
                    size: stat.size,
                    edited: stat.mtime.getTime() / 1000
                });
            }
        }
        #end
    }

    private static function onStateSwitch(newState:FlxState) {
        // Assets.cache.clear();
        // lime.utils.Assets.cache.clear();

        // #if MOD_SUPPORT
        //     if (currentModFolder == null) return;
        //     var bmapsToRemove:Array<FlxGraphic> = [];
        //     @:privateAccess
        //     for(bmap in FlxG.bitmap._cache) {
        //         if (bmap.assetsKey != null) {
        //             var e = new LimeLibrarySymbol(bmap.assetsKey);
        //             if (e.library is openfl.utils.AssetLibrary) {
        //                 @:privateAccess
        //                 e.library = cast(e.library, openfl.utils.AssetLibrary).__proxy;
        //             }
        //             if (e.library is ModsAssetLibrary) {
        //                 var lib = cast(e.library, ModsAssetLibrary);
        //                 if (!lib.__parseAsset(e.symbolName)) continue;
        //                 if (!lib.__isCacheValid(e.library.cachedImages, lib._parsedAsset)) {
        //                     e.library.cachedImages.remove(lib._parsedAsset);
        //                     bmapsToRemove.push(bmap);
        //                 }
        //             }
        //         }
        //     }

        //     // TODO: add setting for cache clearing
        //     @:privateAccess
        //     for(libName=>lib in lime.utils.Assets.libraries) {
        //         var library = lib;
        //         if (library is openfl.utils.AssetLibrary) {
        //             var flLib = cast(library, openfl.utils.AssetLibrary);
        //             @:privateAccess
        //             if (flLib.__proxy != null) library = flLib.__proxy;
        //         }
        //         if (library is ModsAssetLibrary) {
        //             var modLib = cast(library, ModsAssetLibrary);
        //             @:privateAccess
        //             for(sound in library.cachedAudioBuffers)
        //                 sound.dispose();
        //             @:privateAccess
        //             library.cachedBytes = [];
                    
        //         }
        //     }
        //     for(e in bmapsToRemove)
        //         FlxG.bitmap.remove(e);
        // #end
    }
}