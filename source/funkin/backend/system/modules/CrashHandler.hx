package funkin.backend.system.modules;

import openfl.events.UncaughtErrorEvent;
import openfl.events.ErrorEvent;
import openfl.errors.Error;
import lime.system.System as LimeSystem;
#if sys
import sys.FileSystem;
import sys.io.File;
#end

class CrashHandler
{
	public static function init():Void
	{
		openfl.Lib.current.loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, onUncaughtError);
		#if cpp
		untyped __global__.__hxcpp_set_critical_error_handler(onError);
		#elseif hl
		hl.Api.setErrorHandler(onError);
		#end
	}

	private static function onUncaughtError(e:UncaughtErrorEvent):Void
	{
		e.preventDefault();
		e.stopPropagation();
		e.stopImmediatePropagation();

		var m:String = e.error;
		if (Std.isOfType(e.error, Error)) {
			var err = cast(e.error, Error);
			m = '${err.message}';
		} else if (Std.isOfType(e.error, ErrorEvent)) {
			var err = cast(e.error, ErrorEvent);
			m = '${err.text}';
		}
		var stack = haxe.CallStack.exceptionStack();
		var stackLabel:String = "";
		for(e in stack) {
			switch(e) {
				case CFunction: stackLabel += "Non-Haxe (C) Function";
				case Module(c): stackLabel += 'Module ${c}';
				case FilePos(parent, file, line, col):
					switch(parent) {
						case Method(cla, func):
							stackLabel += '(${file}) ${cla.split(".").last()}.$func() - line $line';
						case _:
							stackLabel += '(${file}) - line $line';
					}
				case LocalFunction(v):
					stackLabel += 'Local Function ${v}';
				case Method(cl, m):
					stackLabel += '${cl} - ${m}';
			}
			stackLabel += "\r\n";
		}

		#if sys
		try
		{
			if (!FileSystem.exists('crash'))
				FileSystem.createDirectory('crash');

			File.saveContent('crash/' + Date.now().toString().replace(' ', '-').replace(':', "'") + '.txt', '$m\n\n$stackLabel');
		}
		catch (e:haxe.Exception)
			trace('Couldn\'t save error message. (${e.message})', null);
		#end

		NativeAPI.showMessageBox("Error!", '$m\n\n$stackLabel', MSG_ERROR);

		#if js
		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		js.Browser.window.location.reload(true);
		#else
		LimeSystem.exit(1);
		#end
	}

	#if (cpp || hl)
	private static function onError(message:Dynamic):Void
	{
		throw Std.string(message);
	}
	#end
}
