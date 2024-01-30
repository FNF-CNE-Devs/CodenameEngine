package funkin.editors.extra;

class PropertyButton extends UIButton {
	public var propertyText:UITextBox;
	public var valueText:UITextBox;

	public function new(property, value) {
		super(0, 0, '', function () {}, 280, 35);
		members.push(propertyText = new UITextBox(5, 5, property, 100, 25));
		members.push(valueText = new UITextBox(propertyText.x + propertyText.bWidth + 10, 5, value, 165, 25));
	}

	public override function update(elapsed) {
		super.update(elapsed);
		propertyText.follow(this, 5, 5);
		valueText.follow(this, propertyText.x + propertyText.bWidth, 5);
	}
}