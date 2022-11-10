package funkin.scripting.events;

class NameEvent extends CancellableEvent {
    /**
     * Name
     */
    public var name:String;

    public function new(name:String) {
        super();
        this.name = name;
    }
}