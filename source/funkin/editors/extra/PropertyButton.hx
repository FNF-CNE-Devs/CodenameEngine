package funkin.editors.extra;

class PropertyButton extends UIButton {
	public var propertyText:UITextBox;
	public var valueText:UITextBox;
	public var deleteButton:UIButton;
	public var deleteIcon:FlxSprite;

	public function new(property, value, parent) {
		super(0, 0, '', function () {}, 280, 35);
		members.push(propertyText = new UITextBox(5, 5, property, 100, 25));
		members.push(valueText = new UITextBox(propertyText.x + propertyText.bWidth + 10, 5, value, 135, 25));

		deleteButton = new UIButton(valueText.x + 135, bHeight/2 - (25/2), "", function () {
			parent.remove(this);
		}, 25, 25);
		deleteButton.color = 0xFFFF0000;
		deleteButton.autoAlpha = false;
		members.push(deleteButton);

		deleteIcon = new FlxSprite(deleteButton.x + (15/2), deleteButton.y + 8).loadGraphic(Paths.image('editors/delete-button'));
		deleteIcon.antialiasing = false;
		members.push(deleteIcon);
	}

	public override function update(elapsed) {
		super.update(elapsed);
		propertyText.follow(this, 5, 5);
		valueText.follow(this, propertyText.x + propertyText.bWidth, 5);
		deleteButton.follow(this, valueText.x + 135, bHeight/2 - (25/2));
		deleteIcon.follow(deleteButton, 5, 5);
	}
}