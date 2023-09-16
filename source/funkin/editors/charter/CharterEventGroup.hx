package funkin.editors.charter;

import funkin.editors.charter.CharterBackdropGroup.EventBackdrop;
import flixel.util.FlxSort;

class CharterEventGroup extends FlxTypedGroup<CharterEvent> {
	public var eventsBackdrop:EventBackdrop;
	var __lastSort:Int = 0;

	public override function update(elapsed:Float) {
		filterEvents();
		if (length != __lastSort)
			sortEvents();

		super.update(elapsed);
	}

	public override function draw() {
		for (event in members) {
			event.eventsBackdrop = eventsBackdrop;
			event.snappedToGrid = true;
		}
		super.draw();
	}

	public inline function sortEvents() {
		__lastSort = length;
		this.sort(function(i, e1, e2) {
			return FlxSort.byValues(FlxSort.ASCENDING, e1.step, e2.step);
		});
	}

	public inline function filterEvents() {
		for (event in members)
			if (event.events.length == 0) {
				remove(event, true);
				event.kill();
			}
	}
}