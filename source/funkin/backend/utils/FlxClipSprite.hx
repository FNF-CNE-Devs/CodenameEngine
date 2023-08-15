package funkin.backend.utils;

import flixel.math.FlxRect;
import flixel.FlxSprite;

class FlxClipSprite extends FlxSprite {
    override function set_clipRect(rect:FlxRect):FlxRect
    {
        clipRect = rect;

        if (frames != null)
            frame = frames.frames[animation.frameIndex];

        return rect;
    }
}