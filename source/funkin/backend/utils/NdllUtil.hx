package funkin.backend.utils;

import lime.app.Application;

/**
 * Small util that allows you to load any function from ndlls via `getFunction`.
 *
 * NDLLs must be in your mod's "ndlls" folder, and must follow this name scheme:
 * - `name-windows.ndll` for Windows targeted ndlls
 * - `name-linux.ndll` for Linux targeted ndlls
 * - `name-mac.ndll` for Mac targeted ndlls
 *
 * If:
 * - The platform does not support NDLLs
 * - The NDLL is not found
 * - The Function cannot be found in the NDLL
 * then an empty function will be returned instead, and a message will be shown in logs.
 */
class NdllUtil {
	#if NDLLS_SUPPORTED
		#if windows public static final os:String = "windows"; #end
		#if linux   public static final os:String = "linux"; #end
		#if macos   public static final os:String = "mac"; #end
		#if android public static final os:String = "android"; #end
	#end

	/**
	 * Returns an function from a Haxe NDLL.
	 * Limited to 20 argument due to a limitation
	 *
	 * @param ndll Name of the NDLL.
	 * @param name Name of the function.
	 * @param args Number of arguments of that function.
	 */
	public static function getFunction(ndll:String, name:String, args:Int):Dynamic {
		#if NDLLS_SUPPORTED
		var func:Dynamic = getFunctionFromPath(Paths.ndll('$ndll-$os'), name, args);

		// I hate this code below, at least it wasnt 390625 switch cases, but like reflect.callmethod doesnt work with c++ functions
		return Reflect.makeVarArgs(function(_args:Array<Dynamic>) {
			var arg0:Dynamic = _args.length > 0 ? _args[0] : null;
			var arg1:Dynamic = _args.length > 1 ? _args[1] : null;
			var arg2:Dynamic = _args.length > 2 ? _args[2] : null;
			var arg3:Dynamic = _args.length > 3 ? _args[3] : null;
			var arg4:Dynamic = _args.length > 4 ? _args[4] : null;
			var arg5:Dynamic = _args.length > 5 ? _args[5] : null;
			var arg6:Dynamic = _args.length > 6 ? _args[6] : null;
			var arg7:Dynamic = _args.length > 7 ? _args[7] : null;
			var arg8:Dynamic = _args.length > 8 ? _args[8] : null;
			var arg9:Dynamic = _args.length > 9 ? _args[9] : null;
			var arg10:Dynamic = _args.length > 10 ? _args[10] : null;
			var arg11:Dynamic = _args.length > 11 ? _args[11] : null;
			var arg12:Dynamic = _args.length > 12 ? _args[12] : null;
			var arg13:Dynamic = _args.length > 13 ? _args[13] : null;
			var arg14:Dynamic = _args.length > 14 ? _args[14] : null;
			var arg15:Dynamic = _args.length > 15 ? _args[15] : null;
			var arg16:Dynamic = _args.length > 16 ? _args[16] : null;
			var arg17:Dynamic = _args.length > 17 ? _args[17] : null;
			var arg18:Dynamic = _args.length > 18 ? _args[18] : null;
			var arg19:Dynamic = _args.length > 19 ? _args[19] : null;

			return switch(_args.length) {
				case 0:  func();
				case 1:  func(arg0);
				case 2:  func(arg0, arg1);
				case 3:  func(arg0, arg1, arg2);
				case 4:  func(arg0, arg1, arg2, arg3);
				case 5:  func(arg0, arg1, arg2, arg3, arg4);
				case 6:  func(arg0, arg1, arg2, arg3, arg4, arg5);
				case 7:  func(arg0, arg1, arg2, arg3, arg4, arg5, arg6);
				case 8:  func(arg0, arg1, arg2, arg3, arg4, arg5, arg6, arg7);
				case 9:  func(arg0, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8);
				case 10: func(arg0, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9);
				case 11: func(arg0, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10);
				case 12: func(arg0, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11);
				case 13: func(arg0, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12);
				case 14: func(arg0, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13);
				case 15: func(arg0, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14);
				case 16: func(arg0, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15);
				case 17: func(arg0, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16);
				case 18: func(arg0, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17);
				case 19: func(arg0, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18);
				case 20: func(arg0, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18, arg19);
				default: throw "Too many arguments";
			};
			//return Reflect.callMethod(null, func, _args);
		});
		#else
		Logs.trace('NDLLs are not supported on this platform.', WARNING);
		return noop;
		#end
	}

	/**
	 * Returns an function from a Haxe NDLL at specified path.
	 *
	 * @param ndll Asset path to the NDLL.
	 * @param name Name of the function.
	 * @param args Number of arguments of that function.
	 */
	public static function getFunctionFromPath(ndll:String, name:String, args:Int):Dynamic {
		#if NDLLS_SUPPORTED
		if (!Assets.exists(ndll)) {
			Logs.trace('Couldn\'t find ndll at ${ndll}.', WARNING);
			return noop;
		}
		var func = lime.system.CFFI.load(Assets.getPath(ndll), name, args);

		if (func == null) {
			Logs.trace('Method ${name} in ndll ${ndll} with ${args} args was not found.', ERROR);
			return noop;
		}
		return func;
		#else
		Logs.trace('NDLLs are not supported on this platform.', WARNING);
		#end
		return noop;
	}

	@:dox(hide) @:noCompletion static function noop() {}
}