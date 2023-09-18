package funkin.editors;

class SaveWarning {
	public static var showWarning(default, set):Bool;
	public static function set_showWarning(warning:Bool):Bool
		return WindowUtils.preventClosing = showWarning = warning;

	public static var selectionClass:Class<EditorTreeMenu> = null;

	public static function init() {
		showWarning = false;

		WindowUtils.onClosing = function () {
			if (SaveWarning.showWarning) triggerWarning(true);
		}
	}

	public static function triggerWarning(?resetClosing:Bool = false) {
		if (FlxG.state != null && FlxG.state is UIState) {
			FlxG.state.openSubState(new UIWarningSubstate("Unsaved Changes!", "Your changes will be lost if you don't save them. (Can't be recovered)\n\n\nWould you like to Cancel?", 
			[{
				label: "Exit To Menu",
				onClick: function(_) {
					if (selectionClass != null) FlxG.switchState(Type.createInstance(SaveWarning.selectionClass, []));
					if (resetClosing) WindowUtils.resetClosing();
				}
			},
			{
				label: "Cancel",
				onClick: function (_) {if (resetClosing) WindowUtils.resetClosing();}
			}], false));
		}
	}

	public static inline function reset() {
		SaveWarning.showWarning = false;
		SaveWarning.selectionClass = null;
	}
}