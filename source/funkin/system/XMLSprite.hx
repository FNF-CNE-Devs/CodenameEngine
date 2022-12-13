package funkin.system;

import flixel.math.FlxMatrix;
import flixel.math.FlxRect;
import flixel.math.FlxPoint;
import flixel.FlxCamera;
import flixel.math.FlxMath;
import funkin.interfaces.IBeatReceiver;
import flixel.FlxSprite;

@:enum
abstract XMLAnimType(Int) {
    var NONE = 0;
    var BEAT = 1;
    var LOOP = 2;

    public static function fromString(str:String, def:XMLAnimType = NONE) {
        return switch(str.trim().toLowerCase()) {
            case "none":                NONE;
            case "beat" | "onbeat":     BEAT;
            case "loop":                LOOP;
            default:                    def;
        }
    }
}

class XMLSprite extends FlxSprite implements IBeatReceiver {
    public var spriteAnimType:XMLAnimType = NONE;
    public var beatAnims:Array<String> = [];
    public var name:String;
    public var zoomFactor:Float = 1;
    public var initialZoom:Float = 1;

    public override function update(elapsed:Float) {
        super.update(elapsed);
    }

    public function beatHit(curBeat:Int) {
        if (beatAnims.length > 0) {
            var anim = beatAnims[FlxMath.wrap(curBeat, 0, beatAnims.length-1)];
            if (anim != null && anim != "null" && anim != "none")
                animation.play(anim);
        }
    }
    public function stepHit(curBeat:Int) {}

    public override function getScreenBounds(?newRect:FlxRect, ?camera:FlxCamera):FlxRect {
        __doPreZoomScaleProcedure(camera);
        var r = super.getScreenBounds(newRect, camera);
        __doPostZoomScaleProcedure();
        return r;
    }
    public override function drawComplex(camera:FlxCamera) {
        super.drawComplex(camera);
    }

    public override function doAdditionalMatrixStuff(matrix:FlxMatrix, camera:FlxCamera) {
        super.doAdditionalMatrixStuff(matrix, camera);
        matrix.translate(-camera.width / 2, -camera.height / 2);

        var requestedZoom = FlxMath.lerp(1, camera.zoom, zoomFactor);
        var diff = requestedZoom / camera.zoom;
        matrix.scale(diff, diff);
        matrix.translate(camera.width / 2, camera.height / 2);
    }

    public override function getScreenPosition(?point:FlxPoint, ?Camera:FlxCamera):FlxPoint {
        if (__shouldDoScaleProcedure()) {
            __oldScale = FlxPoint.get(scrollFactor.x, scrollFactor.y);
            var requestedZoom = FlxMath.lerp(initialZoom, camera.zoom, zoomFactor);
            var diff = requestedZoom / camera.zoom;

            scrollFactor.scale(1/diff);

            var r = super.getScreenPosition(point, Camera);

            scrollFactor.set(__oldScale.x, __oldScale.y);
            __oldScale.put();
            __oldScale = null;

            return r;
        }
        return super.getScreenPosition(point, Camera);
    }

    // SCALING FUNCS
    #if REGION
    private inline function __shouldDoScaleProcedure()
        return zoomFactor != 1;

    var __oldScale:FlxPoint;
    var __skipZoomProcedure:Bool = false;

    private function __doPreZoomScaleProcedure(camera:FlxCamera) {
        if (__skipZoomProcedure = !__shouldDoScaleProcedure()) return;
        __oldScale = FlxPoint.get(scale.x, scale.y);
        var requestedZoom = FlxMath.lerp(initialZoom, camera.zoom, zoomFactor);
        var diff = requestedZoom / camera.zoom;

        scale.scale(diff);
    }

    private function __doPostZoomScaleProcedure() {
        if (__skipZoomProcedure) return;
        scale.set(__oldScale.x, __oldScale.y);
        __oldScale.put();
        __oldScale = null;
    }
    #end
}