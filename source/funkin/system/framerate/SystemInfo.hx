package funkin.system.framerate;

import flixel.FlxG;
import flixel.math.FlxMath;

class SystemInfo extends FramerateCategory {
    public function new() {
        super("System Info");
    }

    public override function __enterFrame(t:Int) {
        var text = 'System: ${lime.system.System.platformLabel} ${lime.system.System.platformVersion}';
        text += '\nObjs in state: ${FlxG.state.members.length}';
        text += '\nNb cameras: ${FlxG.cameras.list.length}';
        text += '\nCurrent state: ${Type.getClassName(Type.getClass(FlxG.state))}';
        
        this.text.text = text;
        super.__enterFrame(t);
    }
}