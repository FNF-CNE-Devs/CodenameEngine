package funkin.backend.scripting.events;

/**
 * CANCEL this event to customize from 0 the creation part!
 */
final class DialogueBoxCreationEvent extends CancellableEvent
{
	public var name:String;

	public var textTypeSFX:String;
}