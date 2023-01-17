package funkin.system;

import funkin.desktop.DesktopMain;
import openfl.utils.AssetLibrary;
import openfl.utils.AssetCache;
import openfl.text.TextFormat;
import flixel.system.ui.FlxSoundTray;
import funkin.windows.WindowsAPI;
import funkin.menus.BetaWarningState;
import funkin.menus.TitleState;
import funkin.game.Highscore;
import funkin.options.Options;
import flixel.FlxGame;
import flixel.FlxState;
import openfl.Assets;
import flash.Lib;
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
import lime.app.Application;

#if ALLOW_MULTITHREADING
import sys.thread.Thread;
#end
#if sys
import sys.io.File;
#end
// TODO: REMOVE TEST
import funkin.mods.ModsFolder;

class Main extends Sprite
{
	public static var instance:Main;

	var gameWidth:Int = 1280; // Width of the game in pixels (might be less / more in actual pixels depending on your zoom).
	var gameHeight:Int = 720; // Height of the game in pixels (might be less / more in actual pixels depending on your zoom).
	var zoom:Float = -1; // If -1, zoom is automatically calculated to fit the window dimensions.
	var framerate:Int = 120; // How many frames per second the game should run at.
	var skipSplash:Bool = true; // Whether to skip the flixel splash screen that appears in release mode.
	var startFullscreen:Bool = false; // Whether to start the game in fullscreen on desktop targets

	public static var time:Int = 0;

	// You can pretty much ignore everything from here on - your code should go in your states.

	#if ALLOW_MULTITHREADING
	public static var gameThreads:Array<Thread> = [];
	#end

	public static function main():Void
	{
		Lib.current.addChild(instance = new Main());
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


		addChild(new FlxGame(gameWidth, gameHeight, null, zoom, framerate, framerate, skipSplash, startFullscreen));
		loadGameSettings();
		// FlxG.switchState(new TitleState());
		FlxG.switchState(new funkin.menus.BetaWarningState());

		#if !mobile
		addChild(new FramerateField(10, 3, 0xFFFFFF));
		#end
	}

	@:dox(hide)
	public static var audioDisconnected:Bool = false;

	public static var changeID:Int = 0;


	private static var __threadCycle:Int = 0;
	public static function execAsync(func:Void->Void) {
		#if ALLOW_MULTITHREADING
		var thread = gameThreads[(__threadCycle++) % gameThreads.length];
		thread.events.run(func);
		#else
		func();
		#end
	}

	private static function getTimer():Int {
		return time = Lib.getTimer();
	}

	public function loadGameSettings() {
		MemoryUtil.init();
		@:privateAccess
		FlxG.game.getTimer = getTimer;
		#if ALLOW_MULTITHREADING
		for(i in 0...4)
			gameThreads.push(Thread.createWithEventLoop(function() {Thread.current().events.promise();}));
		#end
		Paths.assetsTree = new AssetsLibraryList();

		#if UPDATE_CHECKING
		funkin.updating.UpdateUtil.init();
		#end
		CrashHandler.init();
		Logs.init();
		Paths.init();
		ModsFolder.init();
		DesktopMain.init();
		DiscordUtil.init();
		#if ALLOW_MULTITASKING
		funkin.multitasking.MultiTaskingHandler.init();
		#end
		#if GLOBAL_SCRIPT
		funkin.scripting.GlobalScript.init();
		#end

		#if sys
		if (Sys.args().contains("-livereload")) {
			var pathBack = #if windows
				"../../../../"
			#elseif mac
				"../../../../../../../"
			#else
				""
			#end;

			#if USE_SOURCE_ASSETS
			#if windows
			trace("Used lime test windows. Switching into source assets.");
			#elseif mac
			trace("Used lime test mac. Switching into source assets.");
			#elseif linux
			trace("Used lime test linux. Switching into source assets.");
			#end
			Paths.assetsTree.addLibrary(ModsFolder.loadLibraryFromFolder('assets', './${pathBack}assets/', true));
			Paths.assetsTree.sourceLibsAmount++;
			#end

			var buildNum:Int = Std.parseInt(File.getContent('./${pathBack}buildnumber.txt'));
			buildNum++;
			File.saveContent('./${pathBack}buildnumber.txt', Std.string(buildNum));
		} else {
			#if USE_ADAPTED_ASSETS
			Paths.assetsTree.addLibrary(ModsFolder.loadLibraryFromFolder('assets', './assets/', true));
			Paths.assetsTree.sourceLibsAmount++;
			#end
		}
		#end


		var lib = new AssetLibrary();
		@:privateAccess
		lib.__proxy = Paths.assetsTree;
		Assets.registerLibrary('default', lib);

		funkin.options.PlayerSettings.init();
		FlxG.save.bind('Codename-Engine');
		Options.load();
		Highscore.load();

		FlxG.fixedTimestep = false;

		refreshAssets();

		Conductor.init();
		AudioSwitchFix.init();
		WindowsAPI.setDarkMode(true);
		EventManager.init();
		FlxG.signals.preStateCreate.add(onStateSwitch);

		#if MOD_SUPPORT
		ModsFolder.switchMod("introMod");
		#end

		initTransition();
	}

	public static function refreshAssets() {
		FlxSoundTray.volumeChangeSFX = Paths.sound('menu/volume');

		if (FlxG.game.soundTray != null)
			FlxG.game.soundTray.text.setTextFormat(new TextFormat(Paths.font("vcr.ttf")));
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

	private static function onStateSwitch(newState:FlxState) {
		// manual asset clearing since base openfl one doesnt clear lime one
		// doesnt clear bitmaps since flixel fork does it auto

		var cache = cast(Assets.cache, AssetCache);
		for (key=>font in cache.font)
			cache.removeFont(key);
		for (key=>sound in cache.sound)
			cache.removeSound(key);

		Paths.assetsTree.clearCache();

		MemoryUtil.destroyFlixelZombies();
		MemoryUtil.clearMajor();
	}
}
