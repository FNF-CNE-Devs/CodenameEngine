package funkin.system;

import funkin.mods.ModsAssetLibrary;
import lime.ui.KeyCode;
import openfl.ui.Keyboard;
import openfl.events.KeyboardEvent;
import openfl.text.TextField;
import openfl.text.TextFormat;
import openfl.system.System;
import openfl.display.Application;
import flixel.math.FlxMath;
import flixel.FlxG;
import openfl.display._internal.stats.Context3DStats;
import openfl.display._internal.stats.DrawCallContext;

class FramerateField extends TextField {
    public var showFPS:Bool = true;
    public var showMemory:Bool = true;
    public var showMemoryPeak:Bool = true;

    /**
     * Press F3 to enable
     */
    public var debugMode:Bool = false;

    public var peak:Float = 0;
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
        var totalMemory = MemoryUtil.currentMemUsage();
        if (showMemory || debugMode) {
            text.push('RAM: ${CoolUtil.getSizeString(totalMemory)}');
        }
        if (showMemoryPeak || debugMode) {
            if (peak < totalMemory)
                peak = totalMemory;
            text.push('RAM PEAK: (${CoolUtil.getSizeString(peak)})');
        }
        #end
        #if !release
        text.push('CODENAME ENGINE BETA - BUILD ${funkin.macros.BuildCounterMacro.getBuildNumber()}');
        #end
        if (debugMode) {
            text.push('=== CONDUCTOR INFO ===');
            text.push('Current Song Position: ${Conductor.songPosition} (${Conductor.curBeat} beats - ${Conductor.curStep} steps)');
            text.push('Current BPM: ${Conductor.bpm}');
            text.push('Current speed: ${FlxMath.roundDecimal(Conductor.speed, 2)}x');
            text.push('=== SYSTEM INFO ===');
            text.push('System: ${lime.system.System.platformLabel} ${lime.system.System.platformVersion}');
            text.push('Objs in state: ${FlxG.state.members.length}');
            text.push('Nb cameras: ${FlxG.cameras.list.length}');
            text.push('Current state: ${Type.getClassName(Type.getClass(FlxG.state))}');
            text.push('=== ASSET LIBRARIES TREE ===');
            if (Paths.assetsTree == null)
                text.push('Not initialized yet');
            else {
                for(e in Paths.assetsTree.libraries) {
                    var l = e;
                    if (l is openfl.utils.AssetLibrary) {
                        var al = cast(l, openfl.utils.AssetLibrary);
                        @:privateAccess
                        if (al.__proxy != null) l = al.__proxy;
                    }

                    if (l is ModsAssetLibrary)
                        text.push('${Type.getClassName(Type.getClass(l))} - ${cast(l, ModsAssetLibrary).libName} (${cast(l, ModsAssetLibrary).prefix})');
                    else
                        text.push(Std.string(e));
                }
            }
            #if (gl_stats && !disable_cffi && (!html5 || !canvas))
            text.push('=== STATS ===');
            text.push("totalDC: " + Context3DStats.totalDrawCalls());
            text.push("stageDC: " + Context3DStats.contextDrawCalls(DrawCallContext.STAGE));
            text.push("stage3DDC: " + Context3DStats.contextDrawCalls(DrawCallContext.STAGE3D));
            #end

        }
        this.text = text.join("\n");
    }
}