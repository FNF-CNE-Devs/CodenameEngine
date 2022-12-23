package funkin.desktop.sprites;

import flixel.FlxBasic;
import funkin.desktop.windows.WindowGroup;

class TopMenu extends WindowGroup<FlxBasic> {
    public function new(trees:Array<TopMenuTree>) {
        super();
    }
}

typedef TopMenuTree = {
    var name:String;
    var options:Array<ContextOption>;
}