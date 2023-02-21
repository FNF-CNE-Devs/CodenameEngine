package funkin.macros;

#if !macro
import haxe.macro.Expr.Field;
import haxe.macro.Context;
#end
#if sys
import sys.io.File;
#end

/**
 * Macro that loads the current build number from `buildnumber.txt`, then make it available as an integer.
 * 
 * `buildnumber.txt` is automatically incremented when the engine is launched with `lime test windows`.
 */
class BuildCounterMacro {
    /**
     * Returns the obtained build number.
     */
    public static macro function getBuildNumber():haxe.macro.Expr.ExprOf<Int> {
        #if !display
        var buildNum:Int = Std.parseInt(File.getContent("buildnumber.txt"));
        return macro $v{buildNum+1};
        #else
        return macro $v{0};
        #end
    }
}