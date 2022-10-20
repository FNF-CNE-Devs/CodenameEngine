package funkin.desktop.windows;

import flixel.group.FlxGroup.FlxTypedGroup;

class WindowGroup extends FlxTypedGroup<Window> {
    public override function update(elapsed:Float) {
        // update them backwards, so that the top most window gets the priority
        var i = length-1;
        while(i >= 0) {
            var window = members[i];
            if (window == null || !window.exists) {
                i--;
                continue;
            }
            window.update(elapsed);

            i--;
        }
    }
}