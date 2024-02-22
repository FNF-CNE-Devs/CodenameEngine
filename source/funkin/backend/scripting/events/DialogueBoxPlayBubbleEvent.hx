package funkin.backend.scripting.events;

import flixel.sound.FlxSound;

final class DialogueBoxPlayBubbleEvent extends CancellableEvent
{
	public var bubble:String;

	public var text:String;

	public var speed:Float;

	public var customSFX:FlxSound;

	public var customTypeSFX:Array<FlxSound>;

	public var playNext:Null<Bool>;
}