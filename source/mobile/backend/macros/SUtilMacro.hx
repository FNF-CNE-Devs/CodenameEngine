package mobile.backend.macros;

class SUtilMacro {
	public static function check() {
		#if android
		#if EXTERNAL
		Sys.println("SUtil Warning: EXTERNAL detected, except problems.");
		#elseif MEDIA
		Sys.println("SUtil Warning: MEDIA detected, except problems.");
		#end
		#else
		#if (EXTERNAL || DATA || MEDIA || OBB)
		#error 'You can\'t define that on this platform.';
		#end
		#end
	}
}