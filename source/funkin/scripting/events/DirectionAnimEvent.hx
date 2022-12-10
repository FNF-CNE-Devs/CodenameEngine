package funkin.scripting.events;

class DirectionAnimEvent extends CancellableEvent
{
	/**
		Default animation that will be played
	**/
	public var animName:String;

	/**
		In which direction the animation will be played
	**/
	public var direction:Int;

	/**
		The suffix of the animation (ex: "-alt") - Defaults to ""
	**/
	public var suffix:String;

	/**
		Whenever the animation will play reversed or not.
	**/
	public var reversed:Bool;

	/**
		Whenever the animation will play reversed or not.
	**/
	public var force:Bool;

	/**
		At what frame the animation will start playing
	**/
	public var frame:Int;

	public function new(animName:String, direction:Int, suffix:String = "", reversed:Bool = false, frame:Int = 0)
	{
		super();
		this.animName = animName;
		this.direction = direction;
		this.suffix = suffix;
		this.reversed = reversed;
		this.force = true;
		this.frame = frame;
	}
}
