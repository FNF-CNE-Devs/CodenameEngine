package;

import commands.*;

class Main {
	public static var commands:Array<Command> = [];

	public static function initCommands() {
		commands = [
			{
				names: ["setup"],
				doc: "Setups (or updates) all libraries required for the engine.",
				func: Update.main,
				dDoc: "This command runs through all libraries in libs.xml, and install them.\nIf they're already installed, they will be updated."
			},
			{
				names: ["help", null],
				doc: "Shows help. Pass a command name to get additional help.",
				func: help,
				dDoc: "Usage: help <cmd>\n\nFor example, use \"cne help test\" to get additional help on the test command."
			},
			{
				names: ["test"],
				doc: "Creates a non final test build, then runs it.",
				func: Compiler.test,
				dDoc: "Usage: test <optional args>\n" +
				"\nThis will create a quick debug build binded to the source then run it, which means:" +
				"\n- The assets WON'T be copied over - Assets will be read from the game's source." +
				"\n- This build WON'T be ready for release - Running anywhere else than in the bin folder will result in a crash from missing assets" +
				"\n- This build will also use the mods folder from the source directory." +
				"\n\nIf you want a full build which contains all assets, run \"cne release\" or \"cne test-release\"" +
				"\nAdditional arguments will be sent to the lime compiler."
			},
			{
				names: ["build"],
				doc: "Creates a non final test build, without running it.",
				func: Compiler.build,
				dDoc: "Usage: build <optional arguments>\n" +
				"\nThis will create a quick debug build binded to the source then run it, which means:" +
				"\n- The assets WON'T be copied over - Assets will be read from the game's source." +
				"\n- This build WON'T be ready for release - Running anywhere else than in the bin folder will result in a crash from missing assets" +
				"\n- This build will also use the mods folder from the source directory." +
				"\n\nIf you want a full build which contains all assets, run \"cne release\" or \"cne test-release\"" +
				"\nAdditional arguments will be sent to the lime compiler."
			},
			{
				names: ["release"],
				doc: "Creates a final non debug build, containing all assets.",
				func: Compiler.release,
				dDoc: "Usage: release <optional arguments>\n" +
				"\nThis will create a final ready-for-release build, which means this build will be able to be release on websites such as GameBanana without worrying about source-dependant stuff."
			},
			{
				names: ["test-release"],
				doc: "Creates a final non debug build, containing all assets.",
				func: Compiler.testRelease,
				dDoc: "Usage: release <optional arguments>\n" +
				"\nThis will create and run a final ready-for-release build, which means this build will be able to be release on websites such as GameBanana without worrying about source-dependant stuff."
			}
		];
	}

	public static function main() {
		initCommands();
		var args = Sys.args();
		var commandName = args.shift();
		if (commandName != null)
			commandName = commandName.toLowerCase();
		for(c in commands) {
			if (c.names.contains(commandName)) {
				c.func(args);
				return;
			}
		}
	}

	public static function help(args:Array<String>) {
		var cmdName = args.shift();
		if (cmdName != null) {
			cmdName = cmdName.toLowerCase();

			var matchingCommand = null;
			for(c in commands) if (c.names.contains(cmdName)) {
				matchingCommand = c;
				break;
			}

			if (matchingCommand == null) {
				Sys.println('help - Command named ${cmdName} not found.');
				return;
			}

			Sys.println('${matchingCommand.names.join(", ")}');
			Sys.println("---");
			Sys.println(matchingCommand.dDoc);

			return;
		}
		// shows help
		Sys.println("Codename Engine Command Line utility");
		Sys.println('Available commands (${commands.length}):\n');
		for(line in commands) {
			Sys.println('${line.names.join(", ")} - ${line.doc}');
		}
	}
}

typedef Command = {
	var names:Array<String>;
	var func:Array<String>->Void;
	var ?doc:String;
	var ?dDoc:String;
}