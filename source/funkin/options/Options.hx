package funkin.options;

import funkin.backend.system.Controls;
import openfl.Lib;
import flixel.util.FlxSave;
import flixel.input.keyboard.FlxKey;

@:build(funkin.backend.system.macros.OptionsMacro.build())
@:build(funkin.backend.system.macros.FunkinSaveMacro.build("__save", "__flush", "__load"))
class Options
{
	@:dox(hide) @:doNotSave
	public static var __save:FlxSave;
	@:dox(hide) @:doNotSave
	private static var __eventAdded = false;

	/**
	 * SETTINGS
	 */
	public static var naughtyness:Bool = true; // If you want your game to be on the nice list, disable this.
	public static var downscroll:Bool = false; // If you like OSU Mania or Guitar Hero, then feel free to enable this.
	public static var ghostTapping:Bool = false; // If you're a chicken, go ahead!
	public static var flashingMenu:Bool = true; // If you're sensitive to flashing lights, disable this.
	public static var camZoomOnBeat:Bool = true; // If you don't like it when the camera zooms in on the beat, then don't leave this on.
	public static var fpsCounter:Bool = true; // If the FPS counter is buggin' you, then you can always hide it here.
	public static var autoPause:Bool = true; // If you want the game to pause when you're not focused on it, then you can leave this option as is, but if you wanna listen to the main menu music as you do other stuff, then disable this option and jam to the menu music all you like!
	public static var antialiasing:Bool = true; // If you want your game to look more clean than it already is, there's this stupid option.
	public static var volume:Float = 1; // Ow, my ears.
	public static var week6PixelPerfect:Bool = true; // If you'd like Week 6 to be pixel perfect, then feel free to enable this!
	public static var lowMemoryMode:Bool = false; // If your PC can't handle many background elements, or the fact you want to save on resources, enable this.
	public static var betaUpdates:Bool = false; // This is best left off, not like anyone's gonna need this.
	public static var splashesEnabled:Bool = true; // If you don't like seeing cool splashes when you get a Sick! rating or if it lags on your PC, then disable this.
	public static var hitWindow:Float = 250; // I don't know what this does.
	public static var framerate:Int = 120; // If you want your game to have less friction, set this to a higher value.
	public static var gpuOnlyBitmaps:Bool = #if mac false #else true #end; // causes issues on mac :(
	// This loads graphics to your GPU unless you're on macOS X.

	public static var lastLoadedMod:String = null; // This checks your last loaded mod, which by default is set to null since you're not expected to be loaded into a mod when you first download this.

	/**
	 * EDITORS SETTINGS
	 */
	public static var intensiveBlur:Bool = true; // This makes the backgrounds blurry for when you're focused on an editor window rather than the rest of the game. Disable if needed.
	public static var editorSFX:Bool = true; // This enables fun sound effects for the editors, you can disable them if it distracts you or if you don't like them.
	public static var resizableEditors:Bool = true; // This allows you to be able to resize the window of your game, and have the editors resize with the game window too! Very useful!
	public static var maxUndos:Int = 150; // This controls how many undos you can do in the editors.

	/**
	 * QOL FEATURES
	 */
	public static var freeplayLastSong:String = null; // This value is set to the last played song in Freeplay mode. By default, there is no value.
	public static var freeplayLastDifficulty:String = "normal"; // This value is set to the difficulty of the last played song in Freeplay mode. Although I think it might be broken since the game launches me in Easy mode.

	// CHARTER
	public static var charterMetronomeEnabled:Bool = false; // This enables the metronome in the charter, useful if you need to place notes with an easier beat to follow with.
	public static var charterShowSections:Bool = true; // This shows the sections in the charter, which makes it easier to chart via section.
	public static var charterShowBeats:Bool = true; // This shows the beats of the song.
	public static var charterEnablePlaytestScripts:Bool = true; // This allows you to use Scripts as you playtest a chart.

	/**
	 * PLAYER 1 CONTROLS
	 */
	public static var P1_NOTE_LEFT:Array<FlxKey> = [A];
	public static var P1_NOTE_DOWN:Array<FlxKey> = [S];
	public static var P1_NOTE_UP:Array<FlxKey> = [W];
	public static var P1_NOTE_RIGHT:Array<FlxKey> = [D];
	public static var P1_LEFT:Array<FlxKey> = [A];
	public static var P1_DOWN:Array<FlxKey> = [S];
	public static var P1_UP:Array<FlxKey> = [W];
	public static var P1_RIGHT:Array<FlxKey> = [D];
	public static var P1_ACCEPT:Array<FlxKey> = [ENTER];
	public static var P1_BACK:Array<FlxKey> = [BACKSPACE];
	public static var P1_PAUSE:Array<FlxKey> = [ENTER];
	public static var P1_RESET:Array<FlxKey> = [R];
	public static var P1_SWITCHMOD:Array<FlxKey> = [TAB];

	/**
	 * PLAYER 2 CONTROLS (ALT)
	 */
	public static var P2_NOTE_LEFT:Array<FlxKey> = [LEFT];
	public static var P2_NOTE_DOWN:Array<FlxKey> = [DOWN];
	public static var P2_NOTE_UP:Array<FlxKey> = [UP];
	public static var P2_NOTE_RIGHT:Array<FlxKey> = [RIGHT];
	public static var P2_LEFT:Array<FlxKey> = [LEFT];
	public static var P2_DOWN:Array<FlxKey> = [DOWN];
	public static var P2_UP:Array<FlxKey> = [UP];
	public static var P2_RIGHT:Array<FlxKey> = [RIGHT];
	public static var P2_ACCEPT:Array<FlxKey> = [SPACE];
	public static var P2_BACK:Array<FlxKey> = [ESCAPE];
	public static var P2_PAUSE:Array<FlxKey> = [ESCAPE];
	public static var P2_RESET:Array<FlxKey> = [];
	public static var P2_SWITCHMOD:Array<FlxKey> = [];

	/**
	 * SOLO GETTERS
	 */
	public static var SOLO_NOTE_LEFT(get, null):Array<FlxKey>;
	public static var SOLO_NOTE_DOWN(get, null):Array<FlxKey>;
	public static var SOLO_NOTE_UP(get, null):Array<FlxKey>;
	public static var SOLO_NOTE_RIGHT(get, null):Array<FlxKey>;
	public static var SOLO_LEFT(get, null):Array<FlxKey>;
	public static var SOLO_DOWN(get, null):Array<FlxKey>;
	public static var SOLO_UP(get, null):Array<FlxKey>;
	public static var SOLO_RIGHT(get, null):Array<FlxKey>;
	public static var SOLO_ACCEPT(get, null):Array<FlxKey>;
	public static var SOLO_BACK(get, null):Array<FlxKey>;
	public static var SOLO_PAUSE(get, null):Array<FlxKey>;
	public static var SOLO_RESET(get, null):Array<FlxKey>;
	public static var SOLO_SWITCHMOD(get, null):Array<FlxKey>;

	public static function load() {
		if (__save == null) __save = new FlxSave();
		__save.bind("options", "CodenameEngine");
		__load();

		if (!__eventAdded) {
			Lib.application.onExit.add(function(i:Int) {
				trace("Saving settings...");
				save();
			});
			__eventAdded = true;
		}
		FlxG.sound.volume = volume;
		applySettings();
	}

	public static function applySettings() {
		applyKeybinds();
		FlxG.game.stage.quality = (FlxG.enableAntialiasing = antialiasing) ? LOW : BEST;
		FlxG.autoPause = autoPause;
		FlxG.drawFramerate = FlxG.updateFramerate = framerate;
	}

	public static function applyKeybinds() {
		PlayerSettings.solo.setKeyboardScheme(Solo);
		PlayerSettings.player1.setKeyboardScheme(Duo(true));
		PlayerSettings.player2.setKeyboardScheme(Duo(false));
	}

	public static function save() {
		volume = FlxG.sound.volume;
		__flush();
	}
}
