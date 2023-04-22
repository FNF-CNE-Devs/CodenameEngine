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
	 *
	 * @param ndll Name of the NDLL.
	 * @param name Name of the function.
	 * @param args Number of arguments of that function.
	 */
	public static function getFunction(ndll:String, name:String, args:Int) {
		#if NDLLS_SUPPORTED
		return getFunctionFromPath(Paths.ndll('$ndll-$os'), name, args);
		#else
		Logs.trace('NDLLs are not supported on this platform.', WARNING);
		return function() {};
		#end
	}

	/**
	 * Returns an function from a Haxe NDLL at specified path.
	 *
	 * @param ndll Asset path to the NDLL.
	 * @param name Name of the function.
	 * @param args Number of arguments of that function.
	 */
	public static function getFunctionFromPath(ndll:String, name:String, args:Int) {
		#if NDLLS_SUPPORTED
		if (!Assets.exists(ndll)) {
			Logs.trace('Couldn\'t find ndll at ${ndll}.', WARNING);
			return function() {};
		}
		var func = lime.system.CFFI.load(Assets.getPath(ndll), name, args);

		if (func == null) {
			Logs.trace('Method ${name} in ndll ${ndll} with ${args} args was not found.', ERROR);
			return function() {};
		}
		return func;
		#else
		Logs.trace('NDLLs are not supported on this platform.', WARNING);
		#end
		return function() {};
	}
}