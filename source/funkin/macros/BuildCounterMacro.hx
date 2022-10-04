package funkin.macros;

import haxe.macro.Expr.Field;
import haxe.macro.Context;
import sys.io.File;

class BuildCounterMacro {
    public static function build():Array<Field> {
        var buildNum:Int = Std.parseInt(File.getContent("buildnumber.txt"));
        buildNum++;

        var fields = Context.getBuildFields();
        fields.push({
            name:  "buildNumber",
            access:  [APublic, AStatic, AInline],
            kind: FieldType.FVar(macro:Int, macro $v{buildNum}), 
            pos: Context.currentPos(),
        });
        File.saveContent("buildnumber.txt", Std.string(buildNum));
        return fields;
    }
}