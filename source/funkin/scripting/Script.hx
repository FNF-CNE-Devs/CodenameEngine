package funkin.scripting;

import haxe.io.Path;
import openfl.utils.Assets;

/**
 * Class used for scripting.
 */
class Script {
    /**
     * [Description] All available script extensions
     */
    public static var scriptExtensions:Array<String> = [
        "hx", "hscript", "hsc"
    ];

    /**
     * [Description] Currently executing script.
     */
    public static var curScript:Script = null;

    /**
     * [Description] Script name (with extension)
     */
    public var fileName:String;

    /**
     * [Description] Creates a script from the specified asset path. The language is automatically determined.
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
     * [Description] Creates a new instance of the script class.
     * @param path 
     */
    public function new(path:String) {
        fileName = Path.withoutDirectory(path);
        var oldScript = curScript;
        curScript = this;
        onCreate(path);
        curScript = oldScript;
    }


    /**
     * [Description] Internal. Creates the script.
     * @param path Path to the script.
     */
    public function onCreate(path:String) {}

    /**
     * [Description] Calls the function `func` defined in the script.
     * @param func Name of the function
     * @param parameters (Optional) Parameters of the function.
     * @return Dynamic Result (if void, then null)
     */
    public function call(func:String, ?parameters:Array<Dynamic>):Dynamic {
        var oldScript = curScript;
        curScript = this;

        var result = onCall(func, parameters == null ? [] : parameters);
        
        curScript = oldScript;
        return result;
    }

    /**
     * [Description] Sets a script's parent object so that its properties can be accessed easily. Ex: Passing `PlayState.instace` will allow `boyfriend` to be typed instead of `PlayState.instance.boyfriend`.
     * @param variable Parent variable.
     */
    public function setParent(variable:Dynamic) {}

    /**
     * [Description] Gets the variable `variable` from the script's variables.
     * @param variable Name of the variable.
     * @return Dynamic Variable (or null if it doesn't exists)
     */
    public function get(variable:String):Dynamic {return null;}

    /**
     * [Description] Gets the variable `variable` from the script's variables.
     * @param variable Name of the variable.
     * @return Dynamic Variable (or null if it doesn't exists)
     */
    public function set(variable:String, value:Dynamic):Void {}

    /**
     * [Description] Shows an error from this script.
     * @param text Text of the error (ex: Null Object Reference).
     * @param additionalInfo Additional information you could provide.
     */
    public function error(text:String, ?additionalInfo:Dynamic):Void {
        // TODO: Logs (like on YCE)
        trace('$text');
    }

    /**
     * PRIVATE HANDLERS - DO NOT TOUCH
     */
    private function onCall(func:String, parameters:Array<Dynamic>):Dynamic {
        return null;
    }
}
