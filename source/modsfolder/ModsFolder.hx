package modsfolder;

import openfl.utils.AssetManifest;
import openfl.utils.AssetLibrary;
import sys.FileSystem;
import flixel.FlxG;
import haxe.io.Path;

using StringTools;

class ModsFolder {
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
     * [Description] Loads a mod with the specified name.
     * @param modName Name of the mod
     * @param force Whenever the mod should be reloaded if it has already been loaded
     */
    public static function loadMod(mod:String, ?force:Bool = false) {
        var libName = 'mods/$mod'.toLowerCase();

        if (openfl.utils.Assets.hasLibrary(libName)) {
            if (force)
                openfl.utils.Assets.unloadLibrary(libName);
            else
                return;
        }
        
        var assets:AssetManifest = new AssetManifest();
        assets.name = libName;// for case sensitive shit & correct linux support
        assets.libraryType = null;
        assets.version = 2;
        assets.libraryArgs = [];
        assets.rootPath = '${modsPath}/$mod/';
        assets.assets = [];
        getAssetFiles(assets.assets, '${modsPath}/$mod/', '', libName);
        checkForOutdatedAssets(assets);

        openfl.utils.Assets.registerLibrary(libName, AssetLibrary.fromManifest(assets));
        loadedMods.push(mod);
    }

    public static function getAssetFiles(assets:Array<Dynamic>, rootPath:String, path:String, libraryName:String, prefix:String = "", addRoot:Bool = false) {
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
    }

    public static function checkForOutdatedAssets(assets:AssetManifest) {
        // TODO: Fix this
        // for(e in assets.assets) {
        //     if (e == null) continue;
        //     if (Reflect.hasField(e, "id") && Reflect.hasField(e, "edited")) {
        //         var id = '${assets.name}:${e.id}';
        //         if (getEditedTime(id) < e.edited) {
        //             Assets.cache.clear(id);
        //             @:privateAccess
        //             FlxG.bitmap.removeKey(id);
        //         }
        //         assetEditTimes[id] = e.edited;
        //     }
        // }
    }
}