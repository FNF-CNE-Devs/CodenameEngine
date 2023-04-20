package funkin.editors.charter;

class CharterEventAdd extends UISliceSprite {
	var text:UIText;
	public var sprAlpha:Float = 0;

	public function new() {
		super(0, 0, 100, 34, 'editors/charter/event-spr-add');

		text = new UIText(0, 0, 0, "");
		members.push(text);

		cursor = BUTTON;

	}

	public override function update(elapsed:Float) {
		super.update(elapsed);

		text.follow(this, 20, (bHeight - text.height) / 2);
		alpha = sprAlpha * 0.75;
		text.alpha = sprAlpha;
	}

	public function updatePos(y:Float) {
		this.y = (FlxG.keys.pressed.SHIFT ? y : 40 * (Math.floor((y + 20) / 40))) - (bHeight / 2);
		text.text = "Add event";
		framesOffset = 0;
		x = -(bWidth = 37 + Math.ceil(text.width));
	}

	public function updateEdit(event:CharterEvent) {
		this.y = event.y;
		text.text = "Edit";
		framesOffset = 9;
		x = -(bWidth = 27 + Math.ceil(text.width) + event.bWidth);
	}
}