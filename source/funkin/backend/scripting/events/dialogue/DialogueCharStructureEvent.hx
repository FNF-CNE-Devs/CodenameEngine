package funkin.backend.scripting.events.dialogue;

import haxe.xml.Access;

/**
 * CANCEL this event to customize from 0 the xml structure part!
 */
final class DialogueCharStructureEvent extends CancellableEvent
{
	public var name:String;

	public var position:String;

	public var charData:Access;
}