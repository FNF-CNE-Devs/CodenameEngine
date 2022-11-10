package funkin.scripting.events;

class ResizeEvent extends CancellableEvent {
    /**
     * New width
     */
    public var width:Int;
    /**
     * New height
     */
    public var height:Int;

    /**
     * Old width (may be null)
     */
    public var oldWidth:Null<Int>;

    /**
     * Old height (may be null)
     */
    public var oldHeight:Null<Int>;
    public function new(width:Int, height:Int, ?oldWidth:Int, ?oldHeight:Int) {
        super();
        this.width = width;
        this.height = height;
        this.oldWidth = oldWidth;
        this.oldHeight = oldHeight;
    }
}