package funkin.editors.ui;

class UICheckbox extends UISprite {
	public var checked:Bool = false;
	public var onChecked:Bool->Void = null;

	public var field:UIText;
	public var check:FlxSprite;

	public function new(x:Float, y:Float, text:String, checked:Bool = false, w:Int = 0) {
		super(x, y);
		loadGraphic(Paths.image('editors/ui/checkbox'), true, 20, 20);
		for(frame=>name in ["normal", "hover", "pressed", "checkmark"])
			animation.add(name, [frame], 0, false);

		this.checked = checked;

		field = new UIText(x, y, w, text);
		check = new FlxSprite().loadGraphicFromSprite(this);
		check.animation.play("checkmark");

		members.push(check);
		members.push(field);

		cursor = BUTTON;
	}

	public override function update(elapsed:Float) {
		// ANIMATION HANDLING
		animation.play(hovered ? (pressed ? "pressed" : "hover") : "normal");

		// CHECKMARK HANDLING
		check.alpha = checked ? 1 : 0;
		check.scale.x = CoolUtil.fpsLerp(check.scale.x, 1, 0.25);
		check.scale.y = CoolUtil.fpsLerp(check.scale.y, 1, 0.25);

		// POSITION HANDLING
		updatePositions();

		super.update(elapsed);
	}

	public inline function updatePositions() {
		check.follow(this);
		field.follow(this, 25, 0);
	}

	public override function draw() {
		updatePositions();
		super.draw();
	}

	public override function onHovered() {
		super.onHovered();
		if (FlxG.mouse.justReleased) {
			// clicked
			checked = !checked;
			check.scale.set(1.25, 1.25);

			if (Options.editorSFX)
				CoolUtil.playMenuSFX(checked ? CHECKED : UNCHECKED, 0.5);
			if (onChecked != null)
				onChecked(checked);
		}
	}

	public override function updateButton() {
		__rect.x = x;
		__rect.y = y;
		__rect.width = field.width + 30;
		__rect.height = field.height > height ? field.height : height;
		UIState.state.updateRectButtonHandler(this, __rect, onHovered);
	}
}