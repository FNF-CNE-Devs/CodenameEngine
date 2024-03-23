package funkin.backend.scripting.events;

final class AmountEvent extends CancellableEvent {
	/**
	 * Amount
	 */
	public var amount:Int;

	/**
	 * Shows whether or not psych users complained about this class
	 */
	public var psychUsersComplained:Bool = true;
}