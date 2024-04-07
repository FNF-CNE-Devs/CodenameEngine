package funkin.backend.utils.native;

#if android
class Android
{
	public static function getTotalRam():Null<Float>
	{
		var f = sys.io.File.read('/proc/meminfo');
		var result = f.readAll().toString();
		if (result == "" || result == null || result.charAt(0) != "M") return null;
		var memTotalLine = result.split('\n')[0];
		memTotalLine = memTotalLine.replace(' ', '');
		memTotalLine = memTotalLine.replace('kB', '');
		memTotalLine = memTotalLine.replace('MemTotal:', '');

		return Std.parseFloat(memTotalLine);
	}
}
#end
