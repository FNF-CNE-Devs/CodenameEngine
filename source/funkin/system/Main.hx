package funkin.system;

import funkin.windows.WindowsAPI;
import funkin.menus.TitleState;
import funkin.game.Highscore;
import funkin.options.Options;
import flixel.FlxGame;
import flixel.FlxState;
import openfl.Assets;
import openfl.Lib;
import openfl.display.FPS;
import openfl.display.Sprite;
import openfl.events.Event;
import flixel.FlxG;
import flixel.graphics.FlxGraphic;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.transition.FlxTransitionSprite.GraphicTransTileDiamond;
import flixel.addons.transition.TransitionData;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
#if desktop
import funkin.system.Discord.DiscordClient;
import sys.thread.Thread;
#end
import lime.app.Application;

#if sys
import sys.io.File;
#end
// TODO: REMOVE TEST
import funkin.mods.ModsFolder;

class Main extends Sprite
{
	var gameWidth:Int = 1280; // Width of the game in pixels (might be less / more in actual pixels depending on your zoom).
	var gameHeight:Int = 720; // Height of the game in pixels (might be less / more in actual pixels depending on your zoom).
	var initialState:Class<FlxState> = TitleState; // The FlxState the game starts with.
	var zoom:Float = -1; // If -1, zoom is automatically calculated to fit the window dimensions.
	var framerate:Int = 120; // How many frames per second the game should run at.
	var skipSplash:Bool = true; // Whether to skip the flixel splash screen that appears in release mode.
	var startFullscreen:Bool = false; // Whether to start the game in fullscreen on desktop targets

	// You can pretty much ignore everything from here on - your code should go in your states.

	public static function main():Void
	{
		Lib.current.addChild(new Main());
	}

	public function new()
	{
		super();

		if (stage != null)
		{
			init();
		}
		else
		{
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
	}

	private function init(?E:Event):Void
	{
		if (hasEventListener(Event.ADDED_TO_STAGE))
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
		}

		setupGame();
	}

	private function setupGame():Void
	{
		var stageWidth:Int = Lib.current.stage.stageWidth;
		var stageHeight:Int = Lib.current.stage.stageHeight;

		if (zoom == -1)
		{
			var ratioX:Float = stageWidth / gameWidth;
			var ratioY:Float = stageHeight / gameHeight;
			zoom = Math.min(ratioX, ratioY);
			gameWidth = Math.ceil(stageWidth / zoom);
			gameHeight = Math.ceil(stageHeight / zoom);
		}

		#if !debug
		initialState = TitleState;
		#end


		addChild(new FlxGame(gameWidth, gameHeight, null, zoom, framerate, framerate, skipSplash, startFullscreen));
		loadGameSettings();
		FlxG.switchState(new TitleState());
		
		#if !mobile
		addChild(new FramerateField(10, 3, 0xFFFFFF));
		#end
	}

	@:dox(hide)
	public static var audioDisconnected:Bool = false;
	
	public static var changeID:Int = 0;
	

	public function loadGameSettings() {
		Logs.init();
		
		// TODO: Mod switching
		ModsFolder.init();
		#if MOD_SUPPORT
		ModsFolder.switchMod("introMod");
		#end
		
		#if GLOBAL_SCRIPT
		funkin.scripting.GlobalScript.init();
		#end
		
		#if sys
		if (Sys.args().contains("-livereload")) {
			trace("Used lime test windows. Switching into source assets.");
			ModsFolder.loadLibraryFromFolder('sourceassets', './../../../../assets/');
			@:privateAccess
			Paths.__useSourceAssets = true;

			var buildNum:Int = Std.parseInt(File.getContent("./../../../../buildnumber.txt"));
			buildNum++;
			File.saveContent("./../../../../buildnumber.txt", Std.string(buildNum));
		}
		#end

		funkin.options.PlayerSettings.init();
		FlxG.save.bind('Save');
		Options.load();
		Highscore.load();

		FlxG.fixedTimestep = false;

		Conductor.init();
		AudioSwitchFix.init();
		WindowsAPI.setDarkMode(true);

		
		#if desktop
		DiscordClient.initialize();
		
		Application.current.onExit.add (function (exitCode) {
			DiscordClient.shutdown();
		 });
		#end
		
		initTransition();
	}

	public static function initTransition() {
		var diamond:FlxGraphic = FlxGraphic.fromClass(GraphicTransTileDiamond);
		diamond.persist = true;
		diamond.destroyOnNoUse = false;

		FlxTransitionableState.defaultTransIn = new TransitionData(FADE, 0xFF000000, 1, new FlxPoint(0, -1), {asset: diamond, width: 32, height: 32},
			new FlxRect(-200, -200, FlxG.width * 1.4, FlxG.height * 1.4));
		FlxTransitionableState.defaultTransOut = new TransitionData(FADE, 0xFF000000, 0.7, new FlxPoint(0, 1),
			{asset: diamond, width: 32, height: 32}, new FlxRect(-200, -200, FlxG.width * 1.4, FlxG.height * 1.4));

	}
}
