package funkin.backend.utils;

import openfl.Lib;

class WindowUtils {
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
		prefix = endfix = "";
		updateTitle();
	}

	public static inline function updateTitle()
		Lib.application.window.title = '$prefix$winTitle$endfix';
}