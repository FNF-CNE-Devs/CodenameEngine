package funkin.backend.scripting.events.dialogue;

import haxe.xml.Access;

/**
 * CANCEL this event to customize from 0 the xml structure part!
 */
final class DialogueStructureEvent extends CancellableEvent
{
	public var dialogueData:Access;
}