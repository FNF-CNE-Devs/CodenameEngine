package funkin.saves;

import flixel.util.FlxSave;

/**
 * Class used for saves WITHOUT going through the struggle of type checks
 * Just add your save variables the way you would do in the Options.hx file.
 * The macro will automatically generate the `flush` and `load` functions.
 */
@:build(funkin.system.macros.FunkinSaveMacro.build("save", "flush", "load"))
class FunkinSave {
	// STUFF
	#if REGION
	public static var save(get, null):FlxSave;
	private static inline function get_save()
		return FlxG.save;

	public static function init() {
		FlxG.save.bind('save', 'CodenameEngine');
		load();
	}
	#end

	public static var totalPlayedGames:Int = 0;
	public static var variableOne:String = "";
	public static var coins:Int = 0;
	public static var coolColor:String = "penis";
}