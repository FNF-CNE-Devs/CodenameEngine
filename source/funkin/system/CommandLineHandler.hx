package funkin.system;

import sys.FileSystem;
#if sys
class CommandLineHandler {
    public static function parseCommandLine(cmd:Array<String>) {
        var i:Int = 0;
        while(i < cmd.length) {
            switch(cmd[i]) {
                case null:
                    break;
                case "-h" | "-help" | "help":
                    Sys.println("-- Codename Engine Command Line help --");
                    Sys.println("-help              | Show this help");
                    #if MOD_SUPPORT
                    Sys.println("-mod [mod name]    | Load a specific mod");
                    Sys.println("-modfolder [path]  | Sets the mod folder path");
                    #end
                    Sys.exit(0);
                #if MOD_SUPPORT
                case "-m" | "-mod" | "-currentmod":
                    i++;
                    var arg = cmd[i];
                    if (arg == null) {
                        Sys.println("[ERROR] You need to specify the mod name");
                        Sys.exit(0);
                    } else {
                        // TODO
                    }
                case "-modfolder":
                    i++;
                    var arg = cmd[i];
                    if (arg == null) {
                        Sys.println("[ERROR] You need to specify the mod folder path");
                        Sys.exit(0);
                    } else if (FileSystem.exists(arg)) {
                        funkin.mods.ModsFolder.modsPath = arg;
                    } else {
                        Sys.println('[ERROR] Mod folder at "${arg}" does not exist.');
                        Sys.exit(0);
                    }
                #end
                case "-livereload":
                    // do nothing
                default:
                    Sys.println("Unknown command");
            }
            i++;
        }
    }
}
#end