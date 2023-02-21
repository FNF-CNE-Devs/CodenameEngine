package funkin.system.framerate;

import flixel.FlxG;
import flixel.math.FlxMath;
import funkin.utils.MemoryUtil;

class SystemInfo extends FramerateCategory {
    public function new() {
        super("System Info");
    }

    public override function __enterFrame(t:Int) {
        if (alpha <= 0.05) return;
        _text = 'System: ${lime.system.System.platformLabel} ${lime.system.System.platformVersion}';
        _text += '\nObjs in state: ${FlxG.state.members.length}';
        _text += '\nNb cameras: ${FlxG.cameras.list.length}';
        _text += '\nCurrent state: ${Type.getClassName(Type.getClass(FlxG.state))}';
        _text += '\nGarbage Collector: ${MemoryUtil.disableCount > 0 ? "OFF" : "ON"} (${MemoryUtil.disableCount})';
        
        this.text.text = _text;
        super.__enterFrame(t);
    }
}