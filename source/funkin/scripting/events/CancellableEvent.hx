package funkin.scripting.events;

import funkin.scripting.ScriptPack;

@:allow(ScriptPack)
class CancellableEvent {
    @:dox(hide) public var cancelled:Bool = false;
    @:dox(hide) private var __continueCalls:Bool = false;

    /**
     * Additional data if used in scripts
     */
    public var data:Dynamic = {};

    /**
     * Prevents default action from occuring.
     */
    public function cancel() {
        cancelled = true;
    }

    /**
     * Creates a new cancellable event.
     * This allows scripts to call `cancel()` to cancel the event.
     * @param continueCalls Whenever the `ScriptPack` should continue calling functions from other scripts after a script cancelled the event.
     */
    public function new(continueCalls:Bool) {
        __continueCalls = continueCalls;
    }
}