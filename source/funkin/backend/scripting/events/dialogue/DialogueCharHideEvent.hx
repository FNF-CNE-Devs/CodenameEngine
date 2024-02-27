package funkin.backend.scripting.events.dialogue;

import funkin.game.cutscenes.dialogue.DialogueCharacter.DialogueCharAnimContext;

final class DialogueCharHideEvent extends CancellableEvent
{
	public var animation:String;

	public var lastAnimContext:DialogueCharAnimContext;
}