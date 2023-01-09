package funkin.scripting.events;

import flixel.math.FlxPoint;

class CamMoveEvent extends CancellableEvent {
    /**
     * Final camera position.
     */
    public var position:FlxPoint;

    /**
     * Boyfriend's camera position.
     */
     public var bfCamPos:FlxPoint;

     /**
      * Dad's camera position.
      */
     public var dadCamPos:FlxPoint;

    /**
     * Ratio for lerping between Dad and BF.
     * 0 = Camera focuses dad
     * 0.5 = Duet Camera
     * 1 = Camera focuses BF
     */
    public var ratio:Float = 0;

    /**
     * Whenever the camera focuses BF more than dad.
     */
    public var focusBF:Bool = false;
}