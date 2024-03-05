package funkin.options.keybinds;

import flixel.input.keyboard.FlxKey;

class ChangeKeybindSubState extends MusicBeatSubstate {
	var callback:FlxKey->Void;
	var cancelCallback:Void->Void;

	var stillPressed:Bool = true;
	public override function new(callback:FlxKey->Void, cancelCallback:Void->Void) {
		this.callback = callback;
		this.cancelCallback = cancelCallback;
		super();
	}

	public override function update(elapsed:Float) {
		super.update(elapsed);
		if (stillPressed && controls.ACCEPT)
			return;
		stillPressed = false;

		var key:FlxKey = FlxG.keys.firstJustPressed();
		if (cast(key, Int) <= 0) return;

		if (key == ESCAPE && !FlxG.keys.pressed.SHIFT) {
			close();
			cancelCallback();
			return;
		}
		close();
		callback(key);
		return;
	}
}