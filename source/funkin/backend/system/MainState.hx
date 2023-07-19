package funkin.backend.system;

#if MOD_SUPPORT
import sys.FileSystem;
#end
import funkin.backend.assets.ModsFolder;
import funkin.menus.TitleState;
import funkin.menus.BetaWarningState;
import funkin.editors.charter.EventsData;
import flixel.FlxState;

/**
 * Simple state used for loading the game
 */
class MainState extends FlxState {
	public static var initiated:Bool = false;
	public static var betaWarningShown:Bool = false;
	public override function create() {
		super.create();
		if (!initiated)
			Main.loadGameSettings();
		initiated = true;

		#if sys
		CoolUtil.deleteFolder('./.temp/'); // delete temp folder
		#end
		Options.save();

		FlxG.bitmap.reset();
		FlxG.sound.destroy(true);

		Paths.assetsTree.reset();

		#if MOD_SUPPORT
		if (ModsFolder.currentModFolder != null)
			Paths.assetsTree.addLibrary(ModsFolder.loadModLib('${ModsFolder.modsPath}${ModsFolder.currentModFolder}'));

		if (FileSystem.exists(ModsFolder.addonsPath) && FileSystem.isDirectory(ModsFolder.addonsPath))
			for(addon in [for(dir in FileSystem.readDirectory(ModsFolder.addonsPath)) if (FileSystem.isDirectory('${ModsFolder.addonsPath}$dir')) dir])
				Paths.assetsTree.addLibrary(ModsFolder.loadModLib('${ModsFolder.addonsPath}$addon'));
		#end

		Main.refreshAssets();
		ModsFolder.onModSwitch.dispatch(ModsFolder.currentModFolder);
		DiscordUtil.reloadJsonData();
		EventsData.reloadEvents();
		TitleState.initialized = false;

		if (betaWarningShown)
			FlxG.switchState(new TitleState());
		else {
			FlxG.switchState(new BetaWarningState());
			betaWarningShown = true;
		}

		#if sys
		sys.FileSystem.createDirectory('./.temp/');
		#if windows Sys.command("attrib +h .temp"); #end
		#end
	}
}