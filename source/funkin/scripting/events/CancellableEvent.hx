package funkin.scripting.events;

import funkin.scripting.ScriptPack;

@:allow(ScriptPack)
class CancellableEvent {
    @:dox(hide) public var cancelled:Bool = false;
    @:dox(hide) private var __continueCalls:Bool = true;

    /**
     * Additional data if used in scripts
     */
    public var data:Dynamic = {};

    /**
     * Prevents default action from occuring.
     * @param c Whenever the scripts following this one should be called or not. (Defaults to `true`)
     */
    public function preventDefault(c:Bool = true) {
        cancelled = true;
        __continueCalls = c;
    }

    @:dox(hide)
    public function cancel(c:Bool = true) {preventDefault(c);}

    /**
     * Creates a new cancellable event.
     * This allows scripts to call `cancel()` to cancel the event.
     */
    public function new() {}

    public function toString():String {
        var rep = '[CancellableEvent ${cancelled ? "(Cancelled)" : ""} - ]';
        // TODO: List all fields
        return rep;
    }
}