package funkin.scripting.events;

import funkin.scripting.events.PlayAnimEvent.PlayAnimContext;

class DirectionAnimEvent extends CancellableEvent {
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
        Context of the animation. Is either equal to `SING` or `MISS`.
    **/
    public var context:PlayAnimContext;
    /**
        Whenever the animation will play reversed or not.
    **/
    public var force:Bool;
    /**
        At what frame the animation will start playing
    **/
    public var frame:Int;

    public function new(animName:String, direction:Int, suffix:String = "", context:PlayAnimContext = SING, reversed:Bool = false, frame:Int = 0) {
        super();
        this.animName = animName;
        this.direction = direction;
        this.suffix = suffix;
        this.context = context;
        this.reversed = reversed;
        this.force = true;
        this.frame = frame;
    }
}