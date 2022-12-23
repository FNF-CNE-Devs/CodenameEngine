package funkin.desktop.windows;

import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.FlxObject;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.FlxBasic;
import flixel.FlxCamera;

class WindowGroup<T:FlxBasic> extends FlxTypedGroup<T> {
    public var x:Float = 0;
    public var y:Float = 0;
    public var scrollFactor:FlxPoint = FlxPoint.get(0, 0);
    public var updateScrolls:Bool = true;

    public override function add(obj:T) {
        super.add(obj);

        if (!updateScrolls) return obj;
        if (obj is FlxObject) {
            var o = cast(obj, FlxObject);
            o.x += x;
            o.y += y;
            o.scrollFactor.x = scrollFactor.x;
            o.scrollFactor.y = scrollFactor.y;
        } else if (obj is WindowGroup) {
            var o:WindowGroup<FlxBasic> = cast obj;
            o.x += x;
            o.y += y;
            o.scrollFactor.x = scrollFactor.x;
            o.scrollFactor.y = scrollFactor.y;
        }

        return obj;
    }

    
    
    public function updateScrollFactor(x:Float, y:Float) {
        scrollFactor.set(x, y);
        if (!updateScrolls) return;
        for(obj in members)
            __updateObjScrollFactor(obj);
    }

    private function __updateObjScrollFactor(obj:FlxBasic) {
        if (obj is FlxObject) {
            var o = cast(obj, FlxObject);
            o.scrollFactor.x = scrollFactor.x;
            o.scrollFactor.y = scrollFactor.y;
        } else if (obj is WindowGroup) {
            var o:WindowGroup<FlxBasic> = cast obj;
            o.updateScrollFactor(scrollFactor.x, scrollFactor.y);
        }
    }

    public override function update(elapsed:Float) {
        // update them backwards, so that the top most window gets the priority
        var i = length;

        @:privateAccess var oldDefaultCameras = FlxCamera._defaultCameras;
		@:privateAccess if (cameras != null)    FlxCamera._defaultCameras = cameras;

        while(i > 0) {
            i--;
            var window = members[i];
            if (window == null || !window.exists)
                continue;
            window.update(elapsed);
        }

		@:privateAccess FlxCamera._defaultCameras = oldDefaultCameras;
    }

    public override function destroy() {
        super.destroy();
        scrollFactor.put();
    }
}