package funkin.scripting.events;

class PointEvent extends CancellableEvent
{
	/**
		X position
	**/
	public var x:Float;

	/**
		Y position
	**/
	public var y:Float;

	public function new(x:Float, y:Float)
	{
		super();
		this.x = x;
		this.y = y;
	}
}
