package funkin.scripting.events;

import funkin.game.Note;

class SimpleNoteEvent extends CancellableEvent
{
	/**
		Note that is affected.
	**/
	public var note:Note;

	public function new(note:Note)
	{
		super();
		this.note = note;
	}
}
