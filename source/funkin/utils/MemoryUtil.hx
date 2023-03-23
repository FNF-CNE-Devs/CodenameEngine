package funkin.utils;

import native.HiddenProcess;
#if cpp
import cpp.vm.Gc;
#elseif hl
import hl.Gc;
#elseif java
import java.vm.Gc;
#elseif neko
import neko.vm.Gc;
#end
import openfl.system.System;

#if cpp
@:cppFileCode("
#if defined(HX_WINDOWS)
#include <windows.h>

long long totalMem() {
	unsigned long long allocatedRAM = 0;
	GetPhysicallyInstalledSystemMemory(&allocatedRAM);
	return (allocatedRAM / 1024);
}
#endif
#if define(HX_MAC)
#include <stdio.h>

long long totalMem() {
    int mib [] = { CTL_HW, HW_MEMSIZE };
    int64_t value = 0;
    size_t length = sizeof(value);

    if(-1 == sysctl(mib, 2, &value, &length, NULL, 0))
        return -1; // An error occurred

    return value / 1024 / 1024;
}
#endif
#if defined(HX_LINUX)
#include <sys/sysctl.h>

long long totalMem() {
	FILE *meminfo = fopen('/proc/meminfo', 'r');

	if(meminfo == NULL) return -1;

	char line[256];
	while(fgets(line, sizeof(line), meminfo))
	{
		int ram;
		if(sscanf(line, 'MemTotal: %d kB', &ram) == 1)
		{
			fclose(meminfo);
			return (ram / 1024);
		}
	}

	fclose(meminfo);
	return -1;
}
#endif
")
#end
class MemoryUtil {
	public static var disableCount:Int = 0;

	public static function askDisable() {
		disableCount++;
		if (disableCount > 0)
			disable();
		else
			enable();
	}
	public static function askEnable() {
		disableCount--;
		if (disableCount > 0)
			disable();
		else
			enable();
	}

	public static function init() {}

	public static function clearMinor() {
		#if (cpp || java || neko)
		Gc.run(false);
		#end
	}

	public static function clearMajor() {
		#if cpp
		Gc.run(true);
		Gc.compact();
		#elseif hl
		Gc.major();
		#elseif (java || neko)
		Gc.run(true);
		#end
	}

	public static function enable() {
		#if (cpp || hl)
		Gc.enable(true);
		#end
	}

	public static function disable() {
		#if (cpp || hl)
		Gc.enable(false);
		#end
	}

	#if cpp
    @:functionCode("return totalMem();")
    public static function getTotalMem():Float
    {
        return 0;
    }
	#end

	public static inline function currentMemUsage() {
		#if cpp
		return Gc.memInfo64(Gc.MEM_INFO_USAGE);
		#elseif sys
		return cast(cast(System.totalMemory, UInt), Float);
		#else
		return 0;
		#end
	}


	public static function getMemType():String {
		#if windows
		if (Assets.exists(Paths.ps1("powershell/ramtype"))) {
			var process = new HiddenProcess("powershell", ["-ExecutionPolicy", "ByPass", "-File", (Sys.getCwd() + Paths.ps1("powershell/ramtype")).replace("/", "\\")]);
			if (process.exitCode() == 0) return process.stdout.readAll().toString().trim().split("\n")[0].trim();
		}
		#elseif mac
		var process = new HiddenProcess("system_profiler", ["SPMemoryDataType"]);
		if (process.exitCode() == 0) return process.stdout.readAll().toString().match(/Type: (.+)/)[1];
		#elseif linux
		var process = HiddenProcess("sudo", ["dmidecode", "--type", "17"]);
		if (process.exitCode() != 0) return "Unknown";
		var lines = process.stdout.readAll().toString().split("\n");
		for (line in lines) {
			if (line.indexOf("Type:") == 0) {
				return line.substring("Type:".length).trim();
			}
		}
		#end

		return "Unknown";
	}

	private static var _nb:Int = 0;
	private static var _nbD:Int = 0;
	private static var _zombie:Dynamic;

	public static function destroyFlixelZombies() {
		#if cpp
		// Gc.enterGCFreeZone();

		while ((_zombie = Gc.getNextZombie()) != null) {
			_nb++;
			if (_zombie is flixel.util.FlxDestroyUtil.IFlxDestroyable) {
				flixel.util.FlxDestroyUtil.destroy(cast(_zombie, flixel.util.FlxDestroyUtil.IFlxDestroyable));
				_nbD++;
			}
		}
		Sys.println('Zombies: ${_nb}; IFlxDestroyable Zombies: ${_nbD}');

		// Gc.exitGCFreeZone();
		#end
	}
}