package funkin.scripting.events;

class PlayAnimEvent extends CancellableEvent {
    /**
        Name of the animation that's going to be played.
    **/
    public var animName:String;

    /**
        Whenever the animation will be forced or not.
    **/
    public var force:Bool;

    /**
        Whenever the animation will play in reverse or not
    **/
    public var reverse:Bool;

    /**
        The frame at which the animation will start playing
    **/
    public var startingFrame:Int = 0;

    /**
        Context of the animation
    **/
    public var context:PlayAnimContext;

    public function new(animName:String, force:Bool, reverse:Bool, startingFrame:Int) {
        super();
        this.animName = animName;
        this.force = force;
        this.reverse = reverse;
        this.startingFrame = startingFrame;
    }
}

/**
    Contains all contexts possible for `PlayAnimEvent`.
**/
@:enum
abstract PlayAnimContext(String) = {
    /**
        No context was given for the animation
    **/
    var NONE = null;

    /**
        Whenever a note is hit and a sing animation will be played.
    **/
    var SING = "SING";

    /**
        Whenever a note is missed and a miss animation will be played.
    **/
    var MISS = "MISS";
}