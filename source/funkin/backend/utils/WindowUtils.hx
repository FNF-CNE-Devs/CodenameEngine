package funkin.backend.utils;

import openfl.Lib;

class WindowUtils {
	public static var winTitle(default, set):String;
	private static function set_winTitle(value:String):String {
		winTitle = value;
		updateTitle();
		return value;
	}
	public static var prefix(default, set):String = "";
	private static function set_prefix(value:String):String {
		prefix = value;
		updateTitle();
		return value;
	}
	public static var suffix(default, set):String = "";
	private static function set_suffix(value:String):String {
		suffix = value;
		updateTitle();
		return value;
	}

	public static var preventClosing:Bool = true;
	public static var onClosing:Void->Void;

	static var __triedClosing:Bool = false;
	public static inline function resetClosing() __triedClosing = false;

	public static inline function init() {
		resetTitle();
		resetClosing();

		Lib.application.window.onClose.add(function () {
			if (preventClosing && !__triedClosing) {
				Lib.application.window.onClose.cancel();
				__triedClosing = true;
			}
			if (onClosing != null) onClosing();
		});
	}

	public static inline function resetTitle() {
		winTitle = Lib.application.meta["name"];
		resetAffixes();
	}

	public static inline function resetAffixes() {
		prefix = suffix = "";
		updateTitle();
	}

	public static inline function updateTitle()
		Lib.application.window.title = '$prefix$winTitle$suffix';

	// backwards compat
	@:noCompletion public static var endfix(get, set):String;
	@:noCompletion private static function set_endfix(value:String):String {
		return suffix = value;
	}
	@:noCompletion private static function get_endfix():String {
		return suffix;
	}
}