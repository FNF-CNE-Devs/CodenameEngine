package funkin.editors.extra;

class PropertyButton extends UIButton {
	public var propertyText:UITextBox;
	public var valueText:UITextBox;
	public function new(property, value) {
		super(0, 0, '', function () {}, 280, 35);
		propertyText = new UITextBox(5, 5, property, 125, 25);
		valueText = new UITextBox(135, 5, value, 125, 25);
		members.push(propertyText);
		members.push(valueText);
	}
	public override function update(elapsed) {
		super.update(elapsed);
		propertyText.follow(this, 5, 5);
		valueText.follow(this, 135, 5);
	}
}