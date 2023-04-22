package funkin.backend.scripting.events;

import flixel.FlxState;

final class StateEvent extends CancellableEvent {
	/**
	 * Substate that is about to be opened/closed
	 */
	public var substate:FlxState;
}