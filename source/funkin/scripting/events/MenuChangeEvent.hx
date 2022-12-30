package funkin.scripting.events;

class MenuChangeEvent extends CancellableEvent {
    /**
     * Value after the change
     */
    public var value:Int;

    /**
     * Value before the change
     */
    public var oldValue:Int;

    /**
     * Amount of change
     */
    public var change:Int;

    /**
     * Whenever the menu SFX should be played.
     */
    public var playMenuSFX:Bool = true;

    public function new(oldValue:Int, value:Int, change:Int, playMenuSFX:Bool = true) {
        super();
        this.value = value;
        this.oldValue = value;
        this.change = change;
        this.playMenuSFX = playMenuSFX;
    }
}