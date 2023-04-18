package funkin.backend.scripting.events;

import funkin.game.Note;

final class SimpleNoteEvent extends CancellableEvent {
	/**
		Note that is affected.
	**/
	public var note:Note;
}