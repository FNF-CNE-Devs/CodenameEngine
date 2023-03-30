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
		Compiler.addGlobalMetadata('haxe.CallStack', '@:build(hscript.UsingHandler.build())');
	}
}
#end