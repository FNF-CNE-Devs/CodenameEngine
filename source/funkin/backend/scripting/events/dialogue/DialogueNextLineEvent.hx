package funkin.backend.scripting.events.dialogue;

import funkin.game.cutscenes.DialogueCutscene.DialogueLine;

/**
 * CANCEL this event to prevent continuing with the next dialogue.
 */
final class DialogueNextLineEvent extends CancellableEvent 
{
	/**
	 * If the dialogue has just been opened.
	 */
	public var playFirst:Bool = false;

	/**
	 * The next dialogue line (may be null on start or finish)
	 */
	public var nextDialogue:Null<DialogueLine>;
}