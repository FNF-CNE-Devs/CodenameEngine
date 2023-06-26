package funkin.backend.scripting.events;

final class FreeplayAlphaUpdateEvent extends CancellableEvent {
	/**
	 * The alpha when nothing is playing and isnt selected
	 */
	public var idleAlpha:Float;
	/**
	 * The alpha when something is playing and isnt selected
	 */
	public var idlePlayingAlpha:Float;
	/**
	 * The alpha when nothing is playing and selected
	 */
	public var selectedAlpha:Float;
	/**
	  * The alpha when something is playing and selected
	  */
	public var selectedPlayingAlpha:Float;
	/**
	 * The lerp of the alpha
	 */
	public var lerp:Float;
}