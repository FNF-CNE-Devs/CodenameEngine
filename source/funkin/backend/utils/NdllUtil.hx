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
		return Reflect.makeVarArgs(function(a:Array<Dynamic>) {
			return switch(a.length) {
				case 0:  func();
				case 1:  func(a[0]);
				case 2:  func(a[0], a[1]);
				case 3:  func(a[0], a[1], a[2]);
				case 4:  func(a[0], a[1], a[2], a[3]);
				case 5:  func(a[0], a[1], a[2], a[3], a[4]);
				case 6:  func(a[0], a[1], a[2], a[3], a[4], a[5]);
				case 7:  func(a[0], a[1], a[2], a[3], a[4], a[5], a[6]);
				case 8:  func(a[0], a[1], a[2], a[3], a[4], a[5], a[6], a[7]);
				case 9:  func(a[0], a[1], a[2], a[3], a[4], a[5], a[6], a[7], a[8]);
				case 10: func(a[0], a[1], a[2], a[3], a[4], a[5], a[6], a[7], a[8], a[9]);
				case 11: func(a[0], a[1], a[2], a[3], a[4], a[5], a[6], a[7], a[8], a[9], a[10]);
				case 12: func(a[0], a[1], a[2], a[3], a[4], a[5], a[6], a[7], a[8], a[9], a[10], a[11]);
				case 13: func(a[0], a[1], a[2], a[3], a[4], a[5], a[6], a[7], a[8], a[9], a[10], a[11], a[12]);
				case 14: func(a[0], a[1], a[2], a[3], a[4], a[5], a[6], a[7], a[8], a[9], a[10], a[11], a[12], a[13]);
				case 15: func(a[0], a[1], a[2], a[3], a[4], a[5], a[6], a[7], a[8], a[9], a[10], a[11], a[12], a[13], a[14]);
				case 16: func(a[0], a[1], a[2], a[3], a[4], a[5], a[6], a[7], a[8], a[9], a[10], a[11], a[12], a[13], a[14], a[15]);
				case 17: func(a[0], a[1], a[2], a[3], a[4], a[5], a[6], a[7], a[8], a[9], a[10], a[11], a[12], a[13], a[14], a[15], a[16]);
				case 18: func(a[0], a[1], a[2], a[3], a[4], a[5], a[6], a[7], a[8], a[9], a[10], a[11], a[12], a[13], a[14], a[15], a[16], a[17]);
				case 19: func(a[0], a[1], a[2], a[3], a[4], a[5], a[6], a[7], a[8], a[9], a[10], a[11], a[12], a[13], a[14], a[15], a[16], a[17], a[18]);
				case 20: func(a[0], a[1], a[2], a[3], a[4], a[5], a[6], a[7], a[8], a[9], a[10], a[11], a[12], a[13], a[14], a[15], a[16], a[17], a[18], a[19]);
				default: throw "Too many arguments";
			};
			//return Reflect.callMethod(null, func, a); // wouldnt work for some reason, maybe cause like c++ functions doesnt have reflection enabled
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