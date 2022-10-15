package funkin.system;

import lime.ui.KeyCode;
import openfl.ui.Keyboard;
import openfl.events.KeyboardEvent;
import openfl.text.TextField;
import openfl.text.TextFormat;
import openfl.system.System;
import openfl.display.Application;
import flixel.math.FlxMath;
import flixel.FlxG;

class FramerateField extends TextField {
    public var showFPS:Bool = true;
    public var showMemory:Bool = true;
    public var showMemoryPeak:Bool = true;

    /**
     * Press F3 to enable
     */
    public var debugMode:Bool = false;

    public var peak:UInt = 0;
    public var lastFPS:Float = 0;

    public function new(x:Float = 10, y:Float = 10, color:Int = 0x000000)
    {
        super();

        this.x = x;
        this.y = y;

        selectable = false;
        mouseEnabled = false;
        defaultTextFormat = new TextFormat("_sans", 12, color);
		autoSize = LEFT;

        #if flash
        addEventListener(Event.ENTER_FRAME, function(e)
        {
            var time = Lib.getTimer();
            __enterFrame(time - currentTime);
        });
        #end

        FlxG.stage.addEventListener(KeyboardEvent.KEY_UP, function(e:KeyboardEvent) {
            switch(e.keyCode) {
                case #if web Keyboard.NUMBER_3 #else Keyboard.F3 #end: // 3 on web or F3 on windows, linux and other things that runs code
                    debugMode = !debugMode;
            }
        });
    }

    public override function __enterFrame(t:Float) {
        var text = [];
        if (showFPS || debugMode) {
            lastFPS = CoolUtil.fpsLerp(lastFPS, FlxG.elapsed == 0 ? 0 : (1 / FlxG.elapsed), 0.25);
            text.push('FPS: ${Std.int(lastFPS)}');
        }
        #if !web
        if (showMemory || debugMode) {
            text.push('RAM: ${CoolUtil.getSizeString(System.totalMemory)}');
        }
        if (showMemoryPeak || debugMode) {
            if (peak < System.totalMemory)
                peak = System.totalMemory;
            text.push('RAM PEAK: (${CoolUtil.getSizeString(peak)})');
        }
        #end
        #if !release
        text.push('CODENAME ENGINE ALPHA - BUILD ${funkin.macros.BuildCounterMacro.getBuildNumber()}');
        #end
        if (debugMode) {
            text.push('System: ${lime.system.System.platformLabel} ${lime.system.System.platformVersion}');
            text.push('Objs in state: ${FlxG.state.members.length}');
            text.push('Nb cameras: ${FlxG.cameras.list.length}');
            text.push('Current state: ${Type.getClassName(Type.getClass(FlxG.state))}');
        }
        this.text = text.join("\n");
    }
}