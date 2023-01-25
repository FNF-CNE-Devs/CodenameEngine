package funkin.system.framerate;

import flixel.math.FlxMath;

class ConductorInfo extends FramerateCategory {
    public function new() {
        super("Conductor Info");
    }

    public override function __enterFrame(t:Int) {
        if (alpha <= 0.05) return;
        _text = 'Current Song Position: ${Conductor.songPosition}';
        _text += '\n - ${Conductor.curBeat} beats';
        _text += '\n - ${Conductor.curStep} steps';
        _text += '\nCurrent BPM: ${Conductor.bpm}';
        _text += '\nCurrent speed: ${FlxMath.roundDecimal(Conductor.speed, 2)}x';
        
        this.text.text = _text;
        super.__enterFrame(t);
    }
}