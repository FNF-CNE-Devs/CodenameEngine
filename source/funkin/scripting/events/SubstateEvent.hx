package funkin.scripting.events;

import flixel.FlxSubState;

class SubstateEvent extends CancellableEvent {
    /**
     * Substate that is about to be opened/closed
     */
    public var substate:FlxSubState;

    public function new(substate:FlxSubState) {
        super();
        this.substate = substate;
    }
}