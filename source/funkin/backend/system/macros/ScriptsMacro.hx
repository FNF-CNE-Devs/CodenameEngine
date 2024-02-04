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
			#if THREE_D_SUPPORT "away3d", "flx3d", #end
			#if VIDEO_CUTSCENES "hxvlc.flixel", "hxvlc.openfl", #end
			// BASE HAXE
			"DateTools", "EReg", "Lambda", "StringBuf", "haxe.crypto", "haxe.display", "haxe.exceptions", "haxe.extern", "scripting"
		])
			Compiler.include(inc);

		for(inc in [#if SYS "sys", "openfl.net", "funkin.backend.system.net" #end]) {
			#if !HL
			Compiler.include(inc);
			#else
			// TODO: Hashlink
			//Compiler.include(inc, ["sys.net.UdpSocket", "openfl.net.DatagramSocket"]); // fixes FATAL ERROR : Failed to load function std@socket_set_broadcast
			#end
		}

		Compiler.include("funkin", #if !UPDATE_CHECKING ['funkin.backend.system.updating'] #end);

		#if HL HashLinkFixer.init(); #end
		// Todo rewrite this to use if(Context.defined(""))
	}
}
#end