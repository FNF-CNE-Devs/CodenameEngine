package funkin.backend.scripting.events;

/**
 * CANCEL this event to customize from 0 the creation part!
 */
final class DialogueCharCreationEvent extends CancellableEvent
{
	public var name:String;

	public var position:String;
}