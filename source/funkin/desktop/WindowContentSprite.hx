package funkin.desktop;

import flixel.FlxSprite;
import flixel.FlxCamera;

class WindowContentSprite extends FlxSprite {
    var cam:FlxCamera;
    public override function get_width() {
        return cam.width;
    }
    public override function get_height() {
        return cam.height;
    }

    public function new(x:Float, y:Float, cam:FlxCamera) {
        super(x, y);
        this.cam = cam;
        makeGraphic(cam.width, cam.height, 0xFF000000);
    }

    public override function update(elapsed:Float) {
        super.update(elapsed);
        cam.render()
    }
    public override function draw() {
        super.draw();
    }
}