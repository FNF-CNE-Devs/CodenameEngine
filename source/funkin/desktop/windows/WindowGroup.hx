package funkin.desktop.windows;

import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.FlxBasic;

class WindowGroup<T:FlxBasic> extends FlxTypedGroup<T> {
    public override function update(elapsed:Float) {
        // update them backwards, so that the top most window gets the priority
        var i = length;
        while(i > 0) {
            i--;
            var window = members[i];
            if (window == null || !window.exists)
                continue;
            window.update(elapsed);
        }
    }
}