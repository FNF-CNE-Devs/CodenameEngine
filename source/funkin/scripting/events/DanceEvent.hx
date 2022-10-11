package funkin.scripting.events;

class DanceEvent extends CancellableEvent {
    public var danced:Bool;
    public function new(danced:Bool = false) {
        super();
        this.danced = danced;
    }
}