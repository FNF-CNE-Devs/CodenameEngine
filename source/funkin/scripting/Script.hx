package funkin.scripting;

import haxe.io.Path;

/**
 * Class used for scripting.
 */
class Script {
    /**
     * [Description] Currently executing script.
     */
    public static var curScript:Script = null;

    /**
     * [Description] Creates a script from the specified asset path. The language is automatically determined.
     * @param path 
     */
    public static function create(path:String):Script {
        if (Assets.exists(file)) {
            return switch(Path.extension(path).toLowerCase()) {
                case "hx" | "hscript" | "hsc":  new HScript(path);
                default:                        new DummyScript();
            }
        } else {
            return new DummyScript(path);
        }
    }

    /**
     * [Description] 
     * @param path 
     */
    public function new(path:String) {
        var oldScript = curScript;
        curScript = this;
        create(path);
        curScript = oldScript;
    }


    /**
     * [Description] Internal. Creates the script.
     * @param path Path to the script.
     */
    public function create(path:String) {}
    /**
     * [Description] Calls the function `func` defined in the script.
     * @param func Name of the function
     * @param parameters (Optional) Parameters of the function.
     * @return Dynamic Result (if void, then null)
     */
    public function call(func:String, ?parameters:Array<Dynamic>):Dynamic {}

    /**
     * [Description] Gets the variable `variable` from the script's variables.
     * @param variable Name of the variable.
     * @return Dynamic Variable (or null if it doesn't exists)
     */
    public function get(variable:String):Dynamic {}

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
    public function error(text:String, additionalInfo:Dynamic):Void {}
}
