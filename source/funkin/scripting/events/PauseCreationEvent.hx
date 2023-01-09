package funkin.scripting.events;

/**
 * CANCEL this event to prevent default behaviour!
 */
class PauseCreationEvent extends CancellableEvent {
    /**
     * Music that is going to be played
     */
    public var music:String;

    /**
     * All option names
     */
    public var options:Array<String>;
}