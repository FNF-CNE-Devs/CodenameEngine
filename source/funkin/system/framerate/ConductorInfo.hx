package funkin.system.framerate;

import flixel.math.FlxMath;

class ConductorInfo extends FramerateCategory {
    public function new() {
        super("Conductor Info");
    }

    public override function __enterFrame(t:Int) {
        var text = 'Current Song Position: ${Conductor.songPosition}';
        text += '\n - ${Conductor.curBeat} beats';
        text += '\n - ${Conductor.curStep} steps';
        text += '\nCurrent BPM: ${Conductor.bpm}';
        text += '\nCurrent speed: ${FlxMath.roundDecimal(Conductor.speed, 2)}x';
        
        this.text.text = text;
        super.__enterFrame(t);
    }
}