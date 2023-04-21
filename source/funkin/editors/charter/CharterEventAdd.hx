package funkin.editors.charter;

class CharterEventAdd extends UISliceSprite {
	var text:UIText;
	public var sprAlpha:Float = 0;
	public var step:Float = 0;

	public var curCharterEvent:CharterEvent = null;

	public function new() {
		super(0, 0, 100, 34, 'editors/charter/event-spr-add');

		text = new UIText(0, 0, 0, "");
		members.push(text);

		cursor = BUTTON;

	}

	public override function onHovered() {
		super.onHovered();
		if (FlxG.mouse.justReleased) {
			var state = cast(FlxG.state, Charter);
			if (curCharterEvent != null) {
				FlxG.state.openSubState(new CharterEventScreen(curCharterEvent));
			} else {
				var event:CharterEvent = new CharterEvent(step, []);
				state.eventsGroup.add(event);
				FlxG.state.openSubState(new CharterEventScreen(event));
			}
		}
	}

	public override function update(elapsed:Float) {
		super.update(elapsed);

		text.follow(this, 20, (bHeight - text.height) / 2);
		alpha = sprAlpha * 0.75;
		text.alpha = sprAlpha;
	}

	public function updatePos(y:Float) {
		curCharterEvent = null;
		step = FlxG.keys.pressed.SHIFT ? (y / 40) : Math.floor((y + 20) / 40);
		this.y = (step * 40) - (bHeight / 2);
		text.text = "Add event";
		framesOffset = 0;
		x = -(bWidth = 37 + Math.ceil(text.width));
	}

	public function updateEdit(event:CharterEvent) {
		curCharterEvent = event;
		this.y = event.y;
		text.text = "Edit";
		framesOffset = 9;
		x = -(bWidth = 27 + Math.ceil(text.width) + event.bWidth);
	}
}