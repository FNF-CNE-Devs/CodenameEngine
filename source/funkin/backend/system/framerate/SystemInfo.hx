package funkin.backend.system.framerate;

import funkin.backend.utils.native.HiddenProcess;
import funkin.backend.utils.MemoryUtil;

using StringTools;

class SystemInfo extends FramerateCategory {
	public static var osInfo:String = "Unknown";
	public static var gpuName:String = "Unknown";
	public static var vRAM:String = "Unknown";
	public static var cpuName:String = "Unknown";
	public static var totalMem:String = "Unknown";
	public static var memType:String = "Unknown";

	public static inline function init() {
		osInfo = '${lime.system.System.platformLabel.replace(lime.system.System.platformVersion, "").trim()} ${lime.system.System.platformVersion}';

		#if windows
		var process = new HiddenProcess("wmic", ["cpu", "get", "name"]);
		if (process.exitCode() == 0) cpuName = process.stdout.readAll().toString().trim().split("\n")[1].trim();
		#elseif mac
		var process = new HiddenProcess("sysctl -a | grep brand_string");
		if (process.exitCode() == 0) cpuName = process.stdout.readAll().toString().trim().split(":")[1].trim();
		#elseif linux
		var process = new HiddenProcess("cat", ["/proc/cpuinfo"]);
		if (process.exitCode() != 0) return;

		for (line in  process.stdout.readAll().toString().split("\n")) {
			if (line.indexOf("model name") == 0) {
				cpuName = line.substring(line.indexOf(":") + 2);
				break;
			}
		}
		#end

		@:privateAccess {
			gpuName = Std.string(flixel.FlxG.stage.context3D.gl.getParameter(flixel.FlxG.stage.context3D.gl.RENDERER)).split("/")[0];
			vRAM = CoolUtil.getSizeString(cast(flixel.FlxG.stage.context3D.gl.getParameter(openfl.display3D.Context3D.__glMemoryTotalAvailable), UInt) * 1000);
		}

		#if cpp
		totalMem = Std.string(MemoryUtil.getTotalMem() / 1024) + " GB";
		#end
		memType = MemoryUtil.getMemType();
	}

	public function new() {
		super("System Info");
	}

	public override function __enterFrame(t:Int) {
		if (alpha <= 0.05) return;
		_text = 'System: $osInfo';
		_text += '\nCPU: ${cpuName} ${openfl.system.Capabilities.cpuArchitecture} ${(openfl.system.Capabilities.supports64BitProcesses ? '64-Bit' : '32-Bit')}';
		if (gpuName != cpuName) _text += '\nGPU: ${gpuName}'; // 1000 bytes of vram (apus)
		if (FlxG.stage != null && FlxG.stage.context3D != null)
			_text += '\nVRAM: ${CoolUtil.getSizeString(cast(FlxG.stage.context3D.totalGPUMemory, UInt))} / $vRAM';
		_text += '\nTotal MEM: ${totalMem} $memType';
		_text += '\nGarbage Collector: ${MemoryUtil.disableCount > 0 ? "OFF" : "ON"} (${MemoryUtil.disableCount})';

		this.text.text = _text;
		super.__enterFrame(t);
	}
}