package funkin.scripting;

import flixel.util.FlxDestroyUtil.IFlxDestroyable;
import flixel.FlxBasic;
import haxe.io.Path;
import openfl.utils.Assets;

/**
 * Class used for scripting.
 */
class Script extends FlxBasic implements IFlxDestroyable {
    /**
     * Use "static var thing = true;" in hscript to use those!!
     * are reset every mod switch so once youre done with them make sure to make them null!!
     */
    public static var staticVariables:Map<String, Dynamic> = [];


    public static function getDefaultVariables():Map<String, Dynamic> {
        return [
            // Haxe related stuff
            "Std"               => Std,
            "Math"              => Math,
            "StringTools"       => StringTools,
            "Json"              => haxe.Json,
    
            // OpenFL & Lime related stuff
            "Assets"            => openfl.utils.Assets,
            "Application"       => lime.app.Application,
            "window"            => lime.app.Application.current.window,
    
            // Flixel related stuff
            "FlxG"              => flixel.FlxG,
            "FlxSprite"         => flixel.FlxSprite,
            "FlxEase"           => flixel.tweens.FlxEase,
            "FlxTween"          => flixel.tweens.FlxTween,
            "FlxCamera"         => flixel.FlxCamera,
            "state"             => flixel.FlxG.state,
            "FlxSound"          => flixel.system.FlxSound,
            "FlxAssets"         => flixel.system.FlxAssets,
            "FlxMath"           => flixel.math.FlxMath,
            "FlxPoint"          => flixel.math.FlxPoint,
            "FlxGroup"          => flixel.group.FlxGroup,
            "FlxTypedGroup"     => flixel.group.FlxGroup.FlxTypedGroup,
            "FlxSpriteGroup"    => flixel.group.FlxSpriteGroup,
            "FlxTypeText"       => flixel.addons.text.FlxTypeText,
            "FlxText"           => flixel.text.FlxText,
            "FlxAxes"           => flixel.util.FlxAxes,
            "FlxTimer"          => flixel.util.FlxTimer,
    
            // Engine related stuff
            "engine"            => {
                build: funkin.macros.BuildCounterMacro.getBuildNumber(),
                name: "Codename Engine"
            },
            "PlayState"         => funkin.game.PlayState,
            "GameOverSubstate"  => funkin.game.GameOverSubstate,
            "Note"              => funkin.game.Note,
            "Strum"             => funkin.game.Strum,
            "Character"         => funkin.game.Character,
            "Boyfriend"         => funkin.game.Character, // for compatibility
            "PauseSubstate"     => funkin.menus.PauseSubState,
            "FreeplayState"     => funkin.menus.FreeplayState,
            "MainMenuState"     => funkin.menus.MainMenuState,
            "PauseSubState"     => funkin.menus.PauseSubState,
            "StoryMenuState"    => funkin.menus.StoryMenuState,
            "TitleState"        => funkin.menus.TitleState,
            "Paths"             => funkin.system.Paths,
            "Conductor"         => funkin.system.Conductor,
            "CoolUtil"          => funkin.system.CoolUtil,
            "FunkinShader"      => funkin.shaders.FunkinShader,
            "CustomShader"      => funkin.shaders.CustomShader,
        ];
    }
    /**
     * All available script extensions
     */
    public static var scriptExtensions:Array<String> = [
        "hx", "hscript", "hsc"
    ];

    /**
     * Currently executing script.
     */
    public static var curScript:Script = null;

    /**
     * Script name (with extension)
     */
    public var fileName:String;

    /**
     * Path to the script.
     */
    public var path:String = null;

    /**
     * Creates a script from the specified asset path. The language is automatically determined.
     * @param path Path in assets
     */
    public static function create(path:String):Script {
        if (Assets.exists(path)) {
            return switch(Path.extension(path).toLowerCase()) {
                case "hx" | "hscript" | "hsc":
                    new HScript(path);
                default:
                    new DummyScript(path);
            }
        }
        return new DummyScript(path);
    }

    /**
     * Creates a new instance of the script class.
     * @param path 
     */
    public function new(path:String) {
        super();

        fileName = Path.withoutDirectory(path);
        this.path = path;
        onCreate(path);
        for(k=>e in getDefaultVariables()) {
            set(k, e);
        }
    }


    /**
     * Loads the script
     */
    public function load() {
        var oldScript = curScript;
        curScript = this;
        onLoad();
        curScript = oldScript;
    }

    /**
     * HSCRIPT ONLY FOR NOW
     * Sets the "public" variables map for ScriptPack
     */
    public function setPublicMap(map:Map<String, Dynamic>) {
        
    }

    /**
     * Hot-reloads the script, if possible
     */
    public function reload() {
        
    }

    /**
     * Traces something as this script.
     */
    public function trace(v:Dynamic) {
        Logs.traceColored([
            Logs.logText('${fileName}: ', GREEN),
            Logs.logText(Std.string(v))
        ], TRACE);
    }

    
    /**
     * Calls the function `func` defined in the script.
     * @param func Name of the function
     * @param parameters (Optional) Parameters of the function.
     * @return Result (if void, then null)
     */
    public function call(func:String, ?parameters:Array<Dynamic>):Dynamic {
        var oldScript = curScript;
        curScript = this;

        var result = onCall(func, parameters == null ? [] : parameters);
        
        curScript = oldScript;
        return result;
    }

    /**
     * Sets a script's parent object so that its properties can be accessed easily. Ex: Passing `PlayState.instace` will allow `boyfriend` to be typed instead of `PlayState.instance.boyfriend`.
     * @param variable Parent variable.
     */
    public function setParent(variable:Dynamic) {}

    /**
     * Gets the variable `variable` from the script's variables.
     * @param variable Name of the variable.
     * @return Variable (or null if it doesn't exists)
     */
    public function get(variable:String):Dynamic {return null;}

    /**
     * Gets the variable `variable` from the script's variables.
     * @param variable Name of the variable.
     * @return Variable (or null if it doesn't exists)
     */
    public function set(variable:String, value:Dynamic):Void {}

    /**
     * Shows an error from this script.
     * @param text Text of the error (ex: Null Object Reference).
     * @param additionalInfo Additional information you could provide.
     */
    public function error(text:String, ?additionalInfo:Dynamic):Void {
        Logs.traceColored([
            Logs.logText(fileName, RED),
            Logs.logText(text)
        ], ERROR);
    }

    /**
     * PRIVATE HANDLERS - DO NOT TOUCH
     */
    private function onCall(func:String, parameters:Array<Dynamic>):Dynamic {
        return null;
    }
    public function onCreate(path:String) {}

    public function onLoad() {}

    public function onDestroy() {};

    public override function destroy() {
        super.destroy();
        onDestroy();
    }
}
