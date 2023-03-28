package funkin.macros;

#if macro
import haxe.macro.Context;
import haxe.macro.Compiler;
import haxe.macro.Expr;

/**
 * Macros containing additional help functions to expand HScript capabilities.
 */
class ScriptsMacro {
	public static function addAdditionalClasses() {
		for(inc in ["flixel", "away3d", "flx3d", "sys", "DateTools", "EReg", "Lambda", "StringBuf", "haxe.crypto", "haxe.display", "haxe.exceptions", "haxe.extern", "scripting"]) {
			Compiler.include(inc);
		}
		
		// FOR ABSTRACTS
		Compiler.addGlobalMetadata('haxe.xml', '@:build(hscript.UsingHandler.build())');
	}

	public static function build():Array<Field> {
		var fields:Array<Field> = Context.getBuildFields();

		for(f in fields) {
			switch(f.kind) {
				case FFun(func):
					if (f.access == null) f.access = [];
					if (f.access.contains(AInline))
						f.access.remove(AInline);
					f.access.push(ADynamic);
				default:
					// do nothing u piece of shit
			}
		}

		return fields;
	}
}
#end