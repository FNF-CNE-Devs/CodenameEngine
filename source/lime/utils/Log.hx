package lime.utils;

import haxe.PosInfos;
#if !macro
import funkin.backend.system.Logs as FunkinLogs;
#end

#if !lime_debug
@:fileXml('tags="haxe,release"')
@:noDebug
#end
class Log
{
	public static var level:LogLevel;

	public static function debug(message:Dynamic, ?info:PosInfos):Void
	{
		if (level >= LogLevel.DEBUG)
		{
			#if js
			untyped __js__("console").debug("[" + info.className + "] " + message);
			#else
			println("[" + info.className + "] " + Std.string(message));
			#end

		}
	}

	public static function error(message:Dynamic, ?info:PosInfos):Void
	{
		if (level >= LogLevel.ERROR)
		{
			var message = '[${info.className}] $message';

			#if !macro
			FunkinLogs.trace(message, ERROR, RED);
			#else
			trace(message);
			#end
		}
	}

	public static function info(message:Dynamic, ?info:PosInfos):Void
	{
		if (level >= LogLevel.INFO) {
			#if !macro
			FunkinLogs.trace('[${info.className}] $message', INFO, RED);
			#else
			trace('[${info.className}] $message');
			#end
		}
	}

	public static inline function print(message:Dynamic):Void
	{
		#if sys
		Sys.print(Std.string(message));
		#elseif flash
		untyped __global__["trace"](Std.string(message));
		#elseif js
		untyped __js__("console").log(message);
		#else
		trace(message);
		#end
	}

	public static inline function println(message:Dynamic):Void
	{
		#if sys
		Sys.println(Std.string(message));
		#elseif flash
		untyped __global__["trace"](Std.string(message));
		#elseif js
		untyped __js__("console").log(message);
		#else
		trace(Std.string(message));
		#end
	}

	public static function verbose(message:Dynamic, ?info:PosInfos):Void
	{
		if (level >= LogLevel.VERBOSE) {
			#if !macro
			FunkinLogs.trace('[${info.className}] $message', VERBOSE);
			#else
			trace('[${info.className}] $message');
			#end
		}
	}

	public static function warn(message:Dynamic, ?info:PosInfos):Void
	{
		if (level >= LogLevel.WARN)
		{
			#if !macro
			FunkinLogs.trace('[${info.className}] $message', WARNING, YELLOW);
			#else
			trace('[${info.className}] $message');
			#end
		}
	}

	private static function __init__():Void
	{
		#if no_traces
		level = NONE;
		#elseif verbose
		level = VERBOSE;
		#else
		#if sys
		var args = Sys.args();
		if (args.indexOf("-v") > -1 || args.indexOf("-verbose") > -1)
		{
			level = VERBOSE;
		}
		else
		#end
		{
			#if debug
			level = DEBUG;
			#else
			level = INFO;
			#end
		}
		#end

		#if js
		if (untyped __js__("typeof console") == "undefined")
		{
			untyped __js__("console = {}");
		}
		if (untyped __js__("console").log == null)
		{
			untyped __js__("console").log = function() {};
		}
		#end
	}
}