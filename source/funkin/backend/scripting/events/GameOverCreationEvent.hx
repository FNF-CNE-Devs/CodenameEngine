package funkin.backend.scripting.events;

/**
 * CANCEL this event to prevent default behaviour!
 */
final class GameOverCreationEvent extends CancellableEvent
{
	// TODO: documentation
	public var x:Float;

	public var y:Float;

	public var character:String;

	public var player:Bool;

	public var gameOverSong:String;

	public var bpm:Int;

	public var lossSFX:String;

	public var retrySFX:String;
}
