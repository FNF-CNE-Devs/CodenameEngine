package funkin.editors.charter;

import flixel.math.FlxPoint;

class CharterStrumlineButton extends UISprite {
	public var button:UISprite;
	public var text:UIText;

	public var onClick:Void->Void;

	public override function new(imagePath:String, text:String) {
		super();

		scrollFactor.set(1, 0);
		alpha = 0;

		button = new UISprite();
		button.loadGraphic(Paths.image(imagePath));
		button.scale.set(0.75,0.75);
		button.updateHitbox();
		button.antialiasing = false;
		button.cursor = BUTTON;
		members.push(button);

		this.text = new UIText(0,0, 160, text);
		this.text.alignment = CENTER;
		members.push(this.text);
	}

	var buttonScale:FlxPoint = FlxPoint.get(0,0);

	public override function update(elapsed:Float) {
		button.follow(this, ((40 * 4) - button.width) / 2, 24);
		text.follow(this, 0, 84);

		super.update(elapsed);

		UIState.state.updateSpriteRect(button);
		if(UIState.state.isOverlapping(button, button.__rect)) {
			buttonScale.set(0.85, 0.85);
			if (FlxG.mouse.justReleased && onClick != null) onClick();
		}
		else buttonScale.set(0.75, 0.75);

		button.scale.set(
			FlxMath.lerp(button.scale.x, buttonScale.x, 1/6),
			FlxMath.lerp(button.scale.y, buttonScale.y, 1/6)
		);
	}

	public override function destroy() {
		super.destroy();

		buttonScale.put();
	}
}