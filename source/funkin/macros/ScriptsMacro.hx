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
		Compiler.include("flixel");
		Compiler.include("away3d");
		Compiler.include("flx3d");
		#if (sys && !web)
		Compiler.include("sys");
		#end

		Compiler.include("DateTools");
		Compiler.include("EReg");
		Compiler.include("Lambda");
		Compiler.include("StringBuf");
		Compiler.include("haxe.crypto");
		Compiler.include("haxe.display");
		Compiler.include("haxe.exceptions");
		#if !web
		Compiler.include("haxe.extern");
		#end

		Compiler.include("scripting");

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