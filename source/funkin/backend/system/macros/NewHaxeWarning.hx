package funkin.backend.system.macros;

#if macro
class NewHaxeWarning {
	public static function warn() {
		#if (haxe >= "4.3.0")
			Sys.println("====================");
			Sys.println("[ WARNING ]");
			Sys.println("Compiling with Haxe 4.3.0 or above CAN and WILL end up in compilation errors due to changes in macros.");
			Sys.println("We recommend building the project using Haxe 4.2.5.");
			Sys.println("You can download it here -> https://haxe.org/download/version/4.2.5/");
			Sys.println("====================");
		#end
	}
}
#end