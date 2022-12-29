package funkin.desktop;

import flixel.FlxObject;

class DesktopUtils {
    public static inline function copyProperties(spr1:FlxObject, spr2:FlxObject) {
        spr1.cameras = spr2.cameras;
        spr1.setPosition(spr2.x, spr2.y);
        spr1.scrollFactor.set(spr2.scrollFactor.x, spr2.scrollFactor.y);
    }
}