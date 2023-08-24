package funkin.backend.utils;

import openfl.Lib;

class WindowTitle {
	public static var winTitle(default, set):String;
	public static function set_winTitle(newWinTitle:String):String {
		winTitle = newWinTitle;
		updateTitle();
		return newWinTitle;
	}
	public static var prefix(default, set):String = "";
	public static function set_prefix(newPrefix:String):String {
		prefix = newPrefix;
		updateTitle();
		return newPrefix;
	}
	public static var endfix(default, set):String = "";
	public static function set_endfix(endPrefix:String):String {
		endfix = endPrefix;
		updateTitle();
		return endPrefix;
	}

	public static inline function init()
		reset();

	public static inline function reset() {
		winTitle = Lib.application.meta["name"];
		prefix = endfix = "";
		updateTitle();
	}

	public static inline function updateTitle()
		Lib.application.window.title = '$prefix$winTitle$endfix';
}