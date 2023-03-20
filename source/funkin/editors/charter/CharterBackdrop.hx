package funkin.editors.charter;

import openfl.geom.Rectangle;
import flixel.addons.display.FlxBackdrop;

class CharterBackdrop extends FlxBackdrop {
    public var strumlinesAmount:Int = 1;
    
    public function new() {
        super(null, 1, 1, false, true);

        makeGraphic(160, 160, 0xFF272727, true);
        pixels.lock();
        for(y in 0...4)
            for(x in 0...2)
                pixels.fillRect(new Rectangle(40*((x*2)+(y%2)), 40*y, 40, 40), 0xFF545454);
        pixels.fillRect(new Rectangle(0, 0, 1, 160), 0xFFDDDDDD);
        pixels.fillRect(new Rectangle(159, 0, 1, 160), 0xFFDDDDDD);
        pixels.unlock();
        loadFrame(frame);
    }

    public override function draw() {
        var ogX:Float = x;
        for(_ in 0...strumlinesAmount) {
            super.draw();
            x += width;
        }
        x = ogX;
    }
}

class CharterBackdropDummy extends UISprite {
    var parent:CharterBackdrop;
    public function new(parent:CharterBackdrop) {
        super();
        this.parent = parent;
        cameras = parent.cameras;
    }
    
    public override function updateButton() {
        __rect.x = parent.x;
        __rect.y = 0 - (FlxG.height * (1 - (1 / FlxG.camera.zoom)));
        __rect.width = parent.frameWidth * parent.scale.x * parent.strumlinesAmount;
        __rect.height = FlxG.height / FlxG.camera.zoom;
        UIState.state.updateRectButtonHandler(this, __rect, onHovered);
    }

    public override function draw() {
        @:privateAccess
        __lastDrawCameras = [for(c in cameras) c];
    }
}