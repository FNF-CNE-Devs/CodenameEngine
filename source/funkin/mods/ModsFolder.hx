package funkin.mods;

import openfl.utils.Assets;
import openfl.utils.AssetManifest;
import openfl.utils.AssetLibrary;
import sys.FileSystem;
import flixel.FlxG;
import flixel.FlxState;
import haxe.io.Path;

using StringTools;

class ModsFolder {
    #if sys
    /**
     * Last time the folder was modified.
     */
    public static var lastFolderEditTime:Date = null;
    #end

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
     * [Description] Initialises `mods` folder by adding callbacks and such.
     */
    public static function init() {
        FlxG.signals.preStateCreate.add(onStateSwitch);
    }

    /**
     * [Description] Loads a mod with the specified name.
     * @param modName Name of the mod
     * @param force Whenever the mod should be reloaded if it has already been loaded
     */
    public static function loadMod(mod:String, ?force:Bool = false) {
        var libName = 'mods/$mod'.toLowerCase();

        if (Assets.hasLibrary(libName)) {
            if (force)
                Assets.unloadLibrary(libName);
            else
                checkForOutdatedAssets(cast Assets.getLibrary(libName));
        }
        
        var assets:AssetManifest = new AssetManifest();
        assets.name = libName;// for case sensitive shit & correct linux support
        assets.libraryType = 'funkin.mods.ModsAssetLibrary';
        assets.version = 2;
        assets.libraryArgs = [];
        assets.rootPath = '${modsPath}/$mod/';
        assets.assets = [];
        getAssetFiles(assets.assets, '${modsPath}/$mod/', '', libName);

        var lib = AssetLibrary.fromManifest(assets);
        openfl.utils.Assets.registerLibrary(libName, lib);
        loadedMods.push(mod);
    }

    /**
     * [Description] Gets all assets in folders and put them in the `assets` array.
     * @param assets Array of assets
     * @param rootPath Root path
     * @param path Path inside of the rootPath (ex: `root path/path/path2/`)
     * @param libraryName Name of the library (ex: `mods/my mod/`)
     * @param prefix Prefix for the asset names (ex: `assets/mods/my mod/`)
     * @param addRoot Whenever the root should be added to the paths. Defaults to false
     */
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

    public static function checkForOutdatedAssets(assets:ModsAssetLibrary) {
        // TODO: Fix this
        #if sys
        @:privateAccess
        for(asset=>path in assets.paths) {
            if (asset == null || path == null) continue;
            var editedTime:Null<Float> = assets.getEditedTime(asset);
            if (editedTime == null) continue;
            try {
                var stat = FileSystem.stat(path);
                if (stat.mtime.getTime() > editedTime) {
                    // refresh
                    trace('Refreshing ${asset}');
                    Assets.cache.clear(asset);
                    @:privateAccess
                    FlxG.bitmap.removeKey(asset);
                }
            }
        }
        #end
    }

    private static function onStateSwitch(newState:FlxState) {
        // TODO: assets reloading
        Assets.cache.clear();

        if (currentModFolder == null) return;
        #if sys
            loadMod(currentModFolder, false); // hot reloading 🔥
        #end
    }
}