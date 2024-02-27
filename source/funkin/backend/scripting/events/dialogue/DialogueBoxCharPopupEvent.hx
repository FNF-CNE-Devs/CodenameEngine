package funkin.backend.scripting.events.dialogue;

import funkin.game.cutscenes.dialogue.DialogueCharacter;

final class DialogueBoxCharPopupEvent extends CancellableEvent
{
	public var char:DialogueCharacter;

	public var force:Bool;
}