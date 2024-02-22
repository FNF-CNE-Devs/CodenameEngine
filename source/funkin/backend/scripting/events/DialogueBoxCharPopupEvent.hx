package funkin.backend.scripting.events;

import funkin.game.cutscenes.dialogue.DialogueCharacter;

final class DialogueBoxCharPopupEvent extends CancellableEvent
{
	public var char:DialogueCharacter;
}