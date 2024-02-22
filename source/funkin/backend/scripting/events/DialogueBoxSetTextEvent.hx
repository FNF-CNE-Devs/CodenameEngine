package funkin.backend.scripting.events;

import flixel.sound.FlxSound;

final class DialogueBoxSetTextEvent extends CancellableEvent
{
	public var text:String;

	public var speed:Float;

	public var customTypeSFX:Array<FlxSound>;
}