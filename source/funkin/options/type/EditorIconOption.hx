package funkin.options.type;

import flixel.util.FlxColor;

class EditorIconOption extends IconOption {
	public var flashColor:FlxColor;

	public function new(name:String, desc:String, icon:String, callback:Void->Void, flashColor:FlxColor = 0) {
		super(name, desc, icon, callback);

		this.flashColor = flashColor;
	}
}