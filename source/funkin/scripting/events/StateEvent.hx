package funkin.scripting.events;

import flixel.FlxState;

class StateEvent extends CancellableEvent {
    /**
     * Substate that is about to be opened/closed
     */
    public var substate:FlxState;

    public function new(substate:FlxState) {
        super();
        this.substate = substate;
    }
}