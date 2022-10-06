package funkin.macros;

import haxe.macro.Expr.Field;
import haxe.macro.Context;
import sys.io.File;

class BuildCounterMacro {
    // non functional
    public static macro function getBuildNumber():haxe.macro.Expr.ExprOf<Int> {
        #if !display
        var buildNum:Int = Std.parseInt(File.getContent("buildnumber.txt"));
        return macro $v{buildNum};
        #else
        return macro $v{0};
        #end
    }
}