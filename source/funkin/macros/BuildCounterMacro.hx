package funkin.macros;

import haxe.macro.Expr.Field;
import haxe.macro.Context;
#if sys
import sys.io.File;
#end

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