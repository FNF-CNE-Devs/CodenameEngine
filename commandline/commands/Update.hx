package commands;

import haxe.Json;
import sys.io.File;
import sys.io.Process;
import sys.FileSystem;

class Update {
    public static function main(args:Array<String>) {
        // to prevent messing with currently installed libs
        if (!FileSystem.exists('.haxelib'))
            FileSystem.createDirectory('.haxelib');

        var json:Array<Library> = Json.parse(File.getContent('./hmm.json')).dependencies;
        prettyPrint("Preparing installation...");
        for(lib in json) {
            // install libs
            switch(lib.type) {
                case "haxelib":
                    prettyPrint('Installing "${lib.name}"...');
                    Sys.command('haxelib install ${lib.name} ${lib.version != null ? " " + lib.version : " "}');
                case "git":
                    prettyPrint('Installing "${lib.name}" from git url "${lib.url}"');
					if (lib.ref != null)
                    	Sys.command('haxelib git ${lib.name} ${lib.url} ${lib.ref}');
					else
                    	Sys.command('haxelib git ${lib.name} ${lib.url}');
                default:
                    prettyPrint('Cannot resolve library of type "${lib.type}"');
            }
        }

		var proc = new Process('haxe --version');
		proc.exitCode(true);
		var haxeVer = proc.stdout.readLine();
		if (haxeVer != "4.2.5") {
			// check for outdated haxe
			var curHaxeVer = [for(v in haxeVer.split(".")) Std.parseInt(v)];
			var requiredHaxeVer = [4, 2, 5];
			for(i in 0...requiredHaxeVer.length) {
				if (curHaxeVer[i] < requiredHaxeVer[i]) {
					prettyPrint("!! WARNING !!");
					Sys.println("Your current Haxe version is outdated.");
					Sys.println('You\'re using ${haxeVer}, while the required version is 4.2.5.');
					Sys.println('The engine may not compile with your current version of Haxe.');
					Sys.println('We recommend upgrading to 4.2.5');
					break;
				} else if (curHaxeVer[i] > requiredHaxeVer[i]) {
					prettyPrint("!! WARNING !!"
					+ "\nHaxeFlixel has incompability issues with the latest version of Haxe, 4.3.0 and above, due to macros."
					+ "\nProceeding will cause compilation issues related to macros (ex: cannot access flash package in macro)");
					Sys.println('');
					Sys.println('We recommend downgrading back to 4.2.5.');
					break;
				}
			}
		}
    }

    public static function prettyPrint(text:String) {
        var header = "══════";
        for(i in 0...(text.length-(text.lastIndexOf("\n")+1)))
            header += "═";
        Sys.println("");
        Sys.println('╔$header╗');
        Sys.println('║   $text   ║');
        Sys.println('╚$header╝');
    }
}

typedef Library = {
    var name:String;
    var type:String;
    var version:String;
    var dir:String;
    var ref:String;
    var url:String;
}