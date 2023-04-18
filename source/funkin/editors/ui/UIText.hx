package funkin.editors.ui;

import flixel.util.FlxColor;
import funkin.backend.FunkinText;

class UIText extends FunkinText {
	// PUTTING THIS HERE IN CASE IMMA MAKE FUTURE CHANGES
	public function new(x, y, w, text, size:Int = 15, color:FlxColor = 0xFFFFFFFF) {
		super(x, y, w, text, size, false);
		this.color = color;
	}
}