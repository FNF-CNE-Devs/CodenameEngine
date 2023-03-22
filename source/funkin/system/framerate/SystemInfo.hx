package funkin.system.framerate;

import funkin.utils.MemoryUtil;

class SystemInfo extends FramerateCategory {
    public static var osInfo:String = "Unknown";
    public static var gpuName:String = "Unknown";
    public static var vRAM:String = "-1 MB";
    public static var cpuName:String = "Unknown";

    public static inline function init() {
        osInfo = '${lime.system.System.platformLabel} ${lime.system.System.platformVersion}';
        @:privateAccess {
            gpuName = Std.string(flixel.FlxG.stage.context3D.gl.getParameter(flixel.FlxG.stage.context3D.gl.RENDERER)).split("/")[0];
            vRAM = CoolUtil.getSizeString(cast(flixel.FlxG.stage.context3D.gl.getParameter(openfl.display3D.Context3D.__glMemoryTotalAvailable), UInt) * 1000);
        }

        #if windows
        var process = new sys.io.Process("wmic", ["cpu", "get", "name"]);
        if (process.exitCode() == 0) cpuName = process.stdout.readAll().toString().trim().split("\n")[1];
        #end
    }

    public function new() {
        super("System Info");
    }

    public override function __enterFrame(t:Int) {
        if (alpha <= 0.05) return;
        _text = 'System: $osInfo';
        _text += '\nCPU: ${cpuName} ${openfl.system.Capabilities.cpuArchitecture} ${(openfl.system.Capabilities.supports64BitProcesses ? '64-Bit' : '32-Bit')}';
        _text += '\nGPU: ${gpuName} | VRAM $vRAM';
        _text += '\nGarbage Collector: ${MemoryUtil.disableCount > 0 ? "OFF" : "ON"} (${MemoryUtil.disableCount})';
        
        this.text.text = _text;
        super.__enterFrame(t);
    }
}