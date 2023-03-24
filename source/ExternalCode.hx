package;

#if windows
@:headerCode("#include <windows.h>")
#elseif linux
@:headerCode("#include <stdio.h>")
#elseif mac
@:headerCode("#include <sys/sysctl.h>")
#end
class ExternalCode {
	#if windows
	@:functionCode("
		// simple but effective code
		unsigned long long allocatedRAM = 0;
		GetPhysicallyInstalledSystemMemory(&allocatedRAM);
		return (allocatedRAM / 1024);
	")
	#elseif linux
	@:functionCode('
		FILE *meminfo = fopen("/proc/meminfo", "r");

		if(meminfo == NULL)
			return -1;

		char line[256];
		while(fgets(line, sizeof(line), meminfo))
		{
			int ram;
			if(sscanf(line, "MemTotal: %d kB", &ram) == 1)
			{
				fclose(meminfo);
				return (ram / 1024);
			}
		}

		fclose(meminfo);
		return -1;
	')
	#elseif mac
	@:functionCode('
	int mib [] = { CTL_HW, HW_MEMSIZE };
	int64_t value = 0;
	size_t length = sizeof(value);

	if(-1 == sysctl(mib, 2, &value, &length, NULL, 0))
		return -1; // An error occurred

	return value / 1024 / 1024;
	')
	#end
	public static function getTotalRam():Float
	{
		return 0;
	}
}