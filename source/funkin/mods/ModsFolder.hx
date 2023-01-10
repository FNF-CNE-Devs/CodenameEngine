package funkin.mods;

import funkin.menus.TitleState;
import funkin.system.Main;
import openfl.utils.AssetCache;
import flixel.util.FlxSignal.FlxTypedSignal;
import openfl.utils.Assets;
import openfl.utils.AssetManifest;
import openfl.utils.AssetLibrary;
import flixel.graphics.FlxGraphic;
import flixel.util.FlxSignal.FlxTypedSignal;
import flixel.FlxG;

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
     * Map all loaded mods' folder libraries.
     */
    public static var loadedMods:Map<String, lime.utils.AssetLibrary> = [];
    /**
     * Path to the `mods` folder.
     */
    public static var modsPath:String = "./mods/";

    /**
     * Initialises `mods` folder by adding callbacks and such.
     */
    public static function init() {
        
    }

    /**
     * Loads a mod with the specified name.
     * @param modName Name of the mod
     * @param force Whenever the mod should be reloaded if it has already been loaded
     */
    public static function loadMod(mod:String, force:Bool = false) {
        #if MOD_SUPPORT
        if (mod == null) return null; // may be loading base game

        if (FileSystem.exists('${modsPath}$mod.zip'))
            return loadedMods[mod] = loadLibraryFromZip('mods/$mod'.toLowerCase(), '${modsPath}$mod.zip', force);
        else
            return loadedMods[mod] = loadLibraryFromFolder('mods/$mod'.toLowerCase(), '${modsPath}$mod', force);

        #else
        return null;
        #end
    }

    /**
     * Switches mod - unloads all the other mods, then load this one.
     * @param libName 
     */
    public static function switchMod(mod:String) {
        unloadMod(ModsFolder.currentModFolder);
        Paths.assetsTree.addLibrary(loadMod(ModsFolder.currentModFolder = mod));

        Main.refreshAssets();
        onModSwitch.dispatch(ModsFolder.currentModFolder);
        if (FlxG.sound.music != null && FlxG.sound.music.playing)
            FlxG.sound.music.fadeOut(0.25, 0, function(t) {
                FlxG.sound.music.stop();
            });
        TitleState.initialized = false;
        FlxG.switchState(new TitleState());
    }

    public static function unloadMod(mod:String) {
        if (mod == null) return;
        Paths.assetsTree.clearCache();
        Paths.assetsTree.removeLibrary(loadedMods[mod]);
        Assets.unloadLibrary('mods/$mod'.toLowerCase());
        loadedMods[mod] = null;
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

    public static function prepareModLibrary(libName:String, lib:ModsAssetLibrary, force:Bool = false) {
        var openLib = prepareLibrary(libName, force);
        lib.prefix = 'assets/';
        @:privateAccess
        openLib.__proxy = cast(lib, lime.utils.AssetLibrary);
        Assets.registerLibrary(libName, openLib);
        return openLib;
    }

    public static function loadLibraryFromFolder(libName:String, folder:String, force:Bool = false) {
        return prepareModLibrary(libName, new ModsFolderLibrary(folder, libName), force);
    }

    public static function loadLibraryFromZip(libName:String, zipPath:String, force:Bool = false) {
        return prepareModLibrary(libName, new ZipFolderLibrary(zipPath, libName), force);
    }
}