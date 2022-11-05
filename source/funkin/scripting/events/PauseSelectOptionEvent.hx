package funkin.scripting.events;

class PauseSelectOptionEvent extends CancellableEvent {
    /**
     * Option name thats going to be selected
     */
    public var name:String;

    public function new(name:String) {
        super();
        this.name = name;
    }
}