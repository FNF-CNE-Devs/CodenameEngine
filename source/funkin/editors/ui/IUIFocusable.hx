package funkin.editors.ui;

import lime.ui.KeyModifier;
import lime.ui.KeyCode;

interface IUIFocusable {
	public function onKeyDown(e:KeyCode, modifier:KeyModifier):Void;
	public function onKeyUp(e:KeyCode, modifier:KeyModifier):Void;
	public function onTextInput(text:String):Void;
}