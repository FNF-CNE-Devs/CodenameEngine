package funkin.editors.charter;

import flixel.math.FlxPoint;

class CharterStrumlineAddButton extends UISprite {
	public var addButton:UISprite;
	public var addText:UIText;

	public override function new(?x:Float, ?y:Float) {
		super();

		scrollFactor.set(1, 0);
		alpha = 0;
		
		addButton = new UISprite();
		addButton.loadGraphic(Paths.image("editors/charter/add-strumline"));
		addButton.scale.set(0.75,0.75);
		addButton.updateHitbox();
		addButton.antialiasing = false;
		members.push(addButton);

		addText = new UIText(0,0, 160, "Add New");
		addText.alignment = CENTER;
		members.push(addText);
	}

	var addButtonScale:FlxPoint = FlxPoint.get(0,0);

	public override function update(elapsed:Float) {
		addButton.follow(this, ((40 * 4) - addButton.width) / 2, 18);
		addText.follow(this, 0, 84);

		super.update(elapsed);

		addButton.__rect.x = addButton.x;
		addButton.__rect.y = addButton.y;
		addButton.__rect.width = addButton.width;
		addButton.__rect.height = addButton.height;
		if(UIState.state.isOverlapping(addButton, addButton.__rect)) {
			addButtonScale.set(0.85, 0.85);
			if (FlxG.mouse.justReleased) Charter.instance.createStrumWithUI();
		}
		else addButtonScale.set(0.75, 0.75);

		addButton.scale.set(
			FlxMath.lerp(addButton.scale.x, addButtonScale.x, 1/6),
			FlxMath.lerp(addButton.scale.y, addButtonScale.y, 1/6)
		);
	}
}