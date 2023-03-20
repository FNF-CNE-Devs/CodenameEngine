package funkin.editors.charter;

import flixel.addons.display.FlxBackdrop;

class CharterBackdrop extends FlxBackdrop {
    public var strumlinesAmount:Int = 1;
    
    public function new() {
        super(null, 1, 1, false, true);

        makeGraphic(4, 4, 0xFF272727, true);
        pixels.lock();
        for(y in 0...4)
            for(x in 0...2)
                pixels.setPixel32((x*2)+(y%2), y, 0xFF545454);
        pixels.unlock();
        scale.set(40, 40);
        updateHitbox();
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