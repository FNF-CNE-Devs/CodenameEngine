package funkin.scripting.events;

class SubstateEvent {
    /**
     * Substate that is about to be opened/closed
     */
    public var substate:FlxSubState;

    public function new(substate:FlxSubState) {
        this.substate = substate;
    }
}