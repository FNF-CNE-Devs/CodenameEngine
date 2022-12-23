package funkin.macros;

#if macro
import haxe.macro.Expr;
import haxe.macro.Context;
import haxe.macro.Compiler;

/**
 * Removes all deprecations errors related to `Std.is`
 */
class StdDeprecationsRemover {
    public static function init() {
        Compiler.addGlobalMetadata('Std', '@:build(hscript.UsingHandler.build())');
    }

    public static function build():Array<Field> {
        var fields:Array<Field> = Context.getBuildFields();

        for(f in fields)
            if (f.name == "is")
                f.meta = [for(e in f.meta) if (e.name != ":deprecated") e];

        return fields;
    }
}
#end