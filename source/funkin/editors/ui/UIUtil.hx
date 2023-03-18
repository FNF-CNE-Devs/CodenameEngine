package funkin.editors.ui;

import openfl.ui.Mouse;

class UIUtil {
    public static function follow(spr:FlxSprite, target:FlxSprite, x:Float = 0, y:Float = 0) {
        spr.cameras = target is UISprite ? cast(target, UISprite).__lastDrawCameras : target.cameras;
        spr.setPosition(target.x + x, target.y + y);
        spr.scrollFactor.set(target.scrollFactor.x, target.scrollFactor.y);
    }
}