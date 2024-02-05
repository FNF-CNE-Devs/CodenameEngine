package funkin.editors.charter;

import funkin.editors.charter.CharterBackdropGroup.EventBackdrop;
import flixel.util.FlxSort;

class CharterEventGroup extends FlxTypedGroup<CharterEvent> {
	public var eventsBackdrop:EventBackdrop;

	public var autoSort:Bool = true;
	var __lastSort:Int = 0;

	public override function update(elapsed:Float) {
		filterEvents();
		if (autoSort && members.length != __lastSort)
			sortEvents();

		super.update(elapsed);
	}

	public override function remove(v:CharterEvent, force:Bool = true):CharterEvent {
		v.ID = -1;
		return super.remove(v, force);
	}

	public override function draw() {
		for (event in members) {
			event.eventsBackdrop = eventsBackdrop;
			event.snappedToGrid = true;
		}
		super.draw();
	}

	public inline function sortEvents() {
		__lastSort = members.length;
		this.sort(function(i, e1, e2) {
			return FlxSort.byValues(FlxSort.ASCENDING, e1.step, e2.step);
		});
		updateEventsIDs();
	}

	public inline function updateEventsIDs()
		for (i => n in members) n.ID = i;

	public inline function filterEvents() {
		for (event in members)
			if (event.events.length == 0) {
				remove(event, true);
				event.kill();
			}
	}
}