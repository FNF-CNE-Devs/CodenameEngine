package funkin.editors.ui;

import flixel.graphics.frames.FlxFrame;

class UIButton extends UISliceSprite {
	public var callback:Void->Void = null;
	public var field:UIText;
	public var shouldPress = true;
	public var hasBeenPressed = false;

	public override function new(x:Float, y:Float, text:String, callback:Void->Void, w:Int = 120, h:Int = 32) {
		super(x, y, w, h, 'editors/ui/button');
		this.callback = callback;
		members.push(field = new UIText(x, y, w, text));
		field.alignment = CENTER;
		field.fieldWidth = w;

		cursor = BUTTON;
	}

	public override function resize(w:Int, h:Int) {
		super.resize(w, h);
		if (field != null) field.fieldWidth = w;
	}

	public override function onHovered() {
		super.onHovered();
		if (FlxG.mouse.justPressed) hasBeenPressed = true;
		if (FlxG.mouse.justReleased && callback != null && shouldPress && hasBeenPressed) {
			callback();
			hasBeenPressed = false;
		}
	}

	public override function update(elapsed:Float) {
		field.follow(this, 0, (bHeight - field.height) / 2);
		if (!hovered && hasBeenPressed && FlxG.mouse.justReleased) hasBeenPressed = false;
		if (autoAlpha) alpha = field.alpha = selectable ? 1 : 0.4;
		super.update(elapsed);
	}

	public override function draw() {
		framesOffset = hovered ? (pressed ? 18 : 9) : 0;
		super.draw();
	}
}