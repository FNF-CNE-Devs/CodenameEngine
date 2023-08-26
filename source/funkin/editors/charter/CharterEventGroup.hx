package funkin.editors.charter;

import funkin.editors.charter.CharterBackdrop.EventBackdrop;

class CharterEventGroup extends FlxTypedGroup<CharterEvent> {
	public var eventsBackdrop:EventBackdrop;

	public override function draw() {
		for (event in members) {
			event.eventsBackdrop = eventsBackdrop;
			event.snappedToGrid = true;
		}
		super.draw();
	}
}