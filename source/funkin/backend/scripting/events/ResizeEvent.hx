package funkin.backend.scripting.events;

final class ResizeEvent extends CancellableEvent {
	/**
	 * New width
	 */
	public var width:Int;
	/**
	 * New height
	 */
	public var height:Int;

	/**
	 * Old width (may be null)
	 */
	public var oldWidth:Null<Int>;

	/**
	 * Old height (may be null)
	 */
	public var oldHeight:Null<Int>;
}