import haxe.Json;
import sys.io.File;
import sys.FileSystem;

class Update {
    public static function main() {
        // to prevent messing with currently installed libs
        if (!FileSystem.exists('.haxelib'))
            FileSystem.createDirectory('.haxelib');

        var json:Array<Library> = Json.parse(File.getContent('./hmm.json')).dependencies;
        prettyPrint("Installing libraries...");
        for(lib in json) {
            // install lib.
            switch(lib.type) {
                case "haxelib":
                    prettyPrint('Installing haxelib ${lib.name}...');
                    Sys.command('haxelib install ${lib.name}');
                case "git":
                    prettyPrint('Installing ${lib.name} from git url ${lib.url}');
                    Sys.command('haxelib git ${lib.name} ${lib.url}');
            }
        }
    }

    public static function prettyPrint(text:String) {
        var header = "══════";
        for(i in 0...text.length)
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