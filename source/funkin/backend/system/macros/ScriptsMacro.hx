package funkin.backend.system.macros;

#if macro
import haxe.macro.Context;
import haxe.macro.Compiler;
import haxe.macro.Expr;

/**
 * Macros containing additional help functions to expand HScript capabilities.
 */
class ScriptsMacro {
	public static function addAdditionalClasses() {
		for(inc in [
			// FLIXEL
			"flixel.util", "flixel.ui", "flixel.tweens", "flixel.tile", "flixel.text",
			"flixel.system", "flixel.sound", "flixel.path", "flixel.math", "flixel.input",
			"flixel.group", "flixel.graphics", "flixel.effects", "flixel.animation",
			// FLIXEL ADDONS
			"flixel.addons.api", "flixel.addons.display", "flixel.addons.effects", "flixel.addons.ui",
			"flixel.addons.plugin", "flixel.addons.text", "flixel.addons.tile", "flixel.addons.transition",
			"flixel.addons.util",
			// OTHER LIBRARIES & STUFF
			"away3d", "flx3d", #if sys "sys", #end "openfl.net",
			"funkin.backend.system.net",
			#if VIDEO_CUTSCENES "hxcodec.flixel", "hxcodec.openfl", "hxcodec.lime", #end
			// BASE HAXE
			"DateTools", "EReg", "Lambda", "StringBuf", "haxe.crypto", "haxe.display", "haxe.exceptions", "haxe.extern", "scripting"
		])
			Compiler.include(inc);

		// FOR ABSTRACTS
		Compiler.addGlobalMetadata('haxe.xml', '@:build(hscript.UsingHandler.build())');
		Compiler.addGlobalMetadata('haxe.CallStack', '@:build(hscript.UsingHandler.build())');
	}
}
#end