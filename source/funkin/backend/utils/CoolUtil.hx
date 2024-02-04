package funkin.backend.utils;

import flixel.tweens.FlxTween;
import flixel.system.frontEnds.SoundFrontEnd;
import flixel.sound.FlxSound;
import funkin.backend.system.Conductor;
import flixel.sound.FlxSoundGroup;
import haxe.Json;
import funkin.menus.StoryMenuState.WeekData;
import haxe.io.Path;
import haxe.xml.Access;
import flixel.input.keyboard.FlxKey;
import lime.utils.Assets;
import flixel.animation.FlxAnimation;
import flixel.util.FlxColor;
import flixel.util.FlxAxes;
import flixel.graphics.frames.FlxFrame;
import flixel.graphics.frames.FlxFramesCollection;
import openfl.geom.ColorTransform;
import funkin.backend.chart.Chart;
import haxe.CallStack;

using StringTools;

@:allow(funkin.game.PlayState)
class CoolUtil
{
	public static function getLastExceptionStack():String {
		return CallStack.toString(CallStack.exceptionStack());
	}

	/*
	 * Returns `v` if not null
	 * @param v The value
	 * @return A bool value
	 */
	public static inline function isNotNull(v:Null<Dynamic>):Bool {
		return v != null && !isNaN(v);
	}

	/*
	 * Returns `v` if not null, `defaultValue` otherwise.
	 * @param v The value
	 * @param defaultValue The default value
	 * @return The return value
	 */
	public static inline function getDefault<T>(v:Null<T>, defaultValue:T):T {
		return (v == null || isNaN(v)) ? defaultValue : v;
	}

	/**
	 * Shortcut to parse JSON from an Asset path
	 * @param assetPath Path to the JSON asset.
	 */
	public static function parseJson(assetPath:String) {
		return Json.parse(Assets.getText(assetPath));
	}

	/**
	 * Deletes a folder recursively
	 * @param delete Path to the folder.
	 */
	@:noUsing public static function deleteFolder(delete:String) {
		#if sys
		if (!sys.FileSystem.exists(delete)) return;
		var files:Array<String> = sys.FileSystem.readDirectory(delete);
		for(file in files) {
			if (sys.FileSystem.isDirectory(delete + "/" + file)) {
				deleteFolder(delete + "/" + file);
				sys.FileSystem.deleteDirectory(delete + "/" + file);
			} else {
				try {
					sys.FileSystem.deleteFile(delete + "/" + file);
				} catch(e) {
					Logs.trace("Could not delete " + delete + "/" + file, WARNING);
				}
			}
		}
		#end
	}

	/**
	 * Shortcut to parse a JSON string
	 * @param str Path to the JSON string
	 * @return Parsed JSON
	 */
	public inline static function parseJsonString(str:String)
		return Json.parse(str);

	/**
	 * Whenever a value is NaN or not.
	 * @param v Value
	 */
	public static inline function isNaN(v:Dynamic) {
		if (v is Float || v is Int)
			return Math.isNaN(cast(v, Float));
		return false;
	}

	/**
	 * Returns the last of an Array
	 * @param array Array
	 * @return T Last element
	 */
	public static inline function last<T>(array:Array<T>):T {
		return array[array.length - 1];
	}

	/**
	 * Sets a field's default value, and returns it. In case it already exists, returns the existing one.
	 * @param v Dynamic to set the default value to
	 * @param name Name of the value
	 * @param defaultValue Default value
	 * @return T New/old value.
	 */
	public static function setFieldDefault<T>(v:Dynamic, name:String, defaultValue:T):T {
		if (Reflect.hasField(v, name)) {
			var f:Null<Dynamic> = Reflect.field(v, name);
			if (f != null)
				return cast f;
		}
		Reflect.setField(v, name, defaultValue);
		return defaultValue;
	}

	/**
	 * Add several zeros at the beginning of a string, so that `2` becomes `02`.
	 * @param str String to add zeros
	 * @param num The length required
	 */
	public static inline function addZeros(str:String, num:Int) {
		while(str.length < num) str = '0${str}';
		return str;
	}

	/**
	 * Add several zeros at the end of a string, so that `2` becomes `20`, useful for ms.
	 * @param str String to add zeros
	 * @param num The length required
	 */
	public static inline function addEndZeros(str:String, num:Int) {
		while(str.length < num) str = '${str}0';
		return str;
	}

	/**
	 * Returns a string representation of a size, following this format: `1.02 GB`, `134.00 MB`
	 * @param size Size to convert to string
	 * @return String Result string representation
	 */
	public static function getSizeString(size:Float):String {
		var labels = ["B", "KB", "MB", "GB", "TB"];
		var rSize:Float = size;
		var label:Int = 0;
		while(rSize > 1024 && label < labels.length-1) {
			label++;
			rSize /= 1024;
		}
		return '${Std.int(rSize) + "." + addZeros(Std.string(Std.int((rSize % 1) * 100)), 2)}${labels[label]}';
	}

	/**
	 * Replaces in a string any kind of IP with `[Your IP]` making the string safer to trace.
	 * @param msg String to check and edit
	 * @return String Result without any kind of IP
	 */
	public static inline function removeIP(msg:String):String {
		return ~/\d+.\d+.\d+.\d+/.replace(msg, "[Your IP]");  // For now its just IPs but who knows in the future..  - Nex
	}

	/**
	 * Alternative linear interpolation function for each frame use, without worrying about framerate changes.
	 * @param v1 Begin value
	 * @param v2 End value
	 * @param ratio Ratio
	 * @return Float Final value
	 */
	@:noUsing public static inline function fpsLerp(v1:Float, v2:Float, ratio:Float):Float {
		return FlxMath.lerp(v1, v2, getFPSRatio(ratio));
	}
	/**
	 * Lerps from color1 into color2 (Shortcut to `FlxColor.interpolate`)
	 * @param color1 Color 1
	 * @param color2 Color 2
	 * @param ratio Ratio
	 * @param fpsSensitive Whenever the ratio should be fps sensitive (adapted when game is running at 120 instead of 60)
	 */
	@:noUsing public static inline function lerpColor(color1:FlxColor, color2:FlxColor, ratio:Float, fpsSensitive:Bool = false) {
		if (!fpsSensitive)
			ratio = getFPSRatio(ratio);
		return FlxColor.interpolate(color1, color2, ratio);
	}

	/**
	 * Modifies a lerp ratio based on current FPS to keep a stable speed on higher framerate.
	 * @param ratio Ratio
	 * @return FPS-Modified Ratio
	 */
	@:noUsing public static inline function getFPSRatio(ratio:Float):Float {
		return FlxMath.bound(ratio * 60 * FlxG.elapsed, 0, 1);
	}
	/**
	 * Tries to get a color from a `Dynamic` variable.
	 * @param c `Dynamic` color.
	 * @return The result color, or `null` if invalid.
	 */
	public static function getColorFromDynamic(c:Dynamic):Null<FlxColor> {
		// -1
		if (c is Int) return c;

		// -1.0
		if (c is Float) return Std.int(c);

		// "#FFFFFF"
		if (c is String) return FlxColor.fromString(c);

		// [255, 255, 255]
		if (c is Array) {
			var r:Int = 0;
			var g:Int = 0;
			var b:Int = 0;
			var a:Int = 255;
			var array:Array<Dynamic> = cast c;
			for(k=>e in array) {
				if (e is Int || e is Float) {
					switch(k) {
						case 0:	r = Std.int(e);
						case 1:	g = Std.int(e);
						case 2:	b = Std.int(e);
						case 3:	a = Std.int(e);
					}
				}
			}
			return FlxColor.fromRGB(r, g, b, a);
		}
		return null;
	}

	/**
	 * Plays the main menu theme.
	 * @param fadeIn
	 */
	@:noUsing public static function playMenuSong(fadeIn:Bool = false) {
		if (FlxG.sound.music == null || !FlxG.sound.music.playing)
		{
			playMusic(Paths.music('freakyMenu'), true, fadeIn ? 0 : 1, true, 102);
			FlxG.sound.music.persist = true;
			if (fadeIn)
				FlxG.sound.music.fadeIn(4, 0, 0.7);
		}
	}

	/**
	 * Preloads a character.
	 * @param name Character name
	 * @param spriteName (Optional) sprite name.
	 */
	@:noUsing public static function preloadCharacter(name:String, ?spriteName:String) {
		if (name == null) return;
		if (spriteName == null)
			spriteName = name;
		Assets.getText(Paths.xml('characters/$name'));
		Paths.getFrames('characters/$spriteName');
	}

	/**
	 * Plays music, while resetting the Conductor, and taking info from INI in count.
	 * @param path Path to the music
	 * @param Persist Whenever the music should persist while switching states
	 * @param DefaultBPM Default BPM of the music (102)
	 * @param Volume Volume of the music (1)
	 * @param Looped Whenever the music loops (true)
	 * @param Group A group that this music belongs to (default)
	 */
	@:noUsing public static function playMusic(path:String, Persist:Bool = false, Volume:Int = 1, Looped:Bool = true, DefaultBPM:Int = 102, ?Group:FlxSoundGroup) {
		Conductor.reset();
		FlxG.sound.playMusic(path, Volume, Looped, Group);
		if (FlxG.sound.music != null) {
			FlxG.sound.music.persist = Persist;
		}

		var infoPath = '${Path.withoutExtension(path)}.ini';
		if (Assets.exists(infoPath)) {
			var musicInfo = IniUtil.parseAsset(infoPath, [
				"BPM" => null,
				"TimeSignature" => "4/4"
			]);

			var timeSignParsed:Array<Null<Float>> = musicInfo["TimeSignature"] == null ? [] : [for(s in musicInfo["TimeSignature"].split("/")) Std.parseFloat(s)];
			var beatsPerMeasure:Float = 4;
			var stepsPerBeat:Float = 4;

			// Check later, i dont think timeSignParsed can contain null, only nan
			if (timeSignParsed.length == 2 && !timeSignParsed.contains(null)) {
				beatsPerMeasure = timeSignParsed[0] == null || timeSignParsed[0] <= 0 ? 4 : cast timeSignParsed[0];
				stepsPerBeat = timeSignParsed[1] == null || timeSignParsed[1] <= 0 ? 4 : cast timeSignParsed[1];
			}

			var bpm:Null<Float> = Std.parseFloat(musicInfo["BPM"]).getDefault(DefaultBPM);
			Conductor.changeBPM(bpm, beatsPerMeasure, stepsPerBeat);
		} else
			Conductor.changeBPM(DefaultBPM);
	}

	/**
	 * Plays a specified Menu SFX.
	 * @param menuSFX Menu SFX to play
	 * @param volume At which volume it should play
	 */
	@:noUsing public static inline function playMenuSFX(menuSFX:CoolSfx = SCROLL, volume:Float = 1) {
		FlxG.sound.play(Paths.sound(switch(menuSFX) {
			case CONFIRM:	'menu/confirm';
			case CANCEL:	'menu/cancel';
			case SCROLL:	'menu/scroll';
			case CHECKED:	'menu/checkboxChecked';
			case UNCHECKED:	'menu/checkboxUnchecked';
			case WARNING:	'menu/warningMenu';
			default: 		'menu/scroll';
		}), volume);
	}

	/**
	 * Allows you to split a text file from a path, into a "cool text file", AKA a list. Allows for comments. For example,
	 * `# comment`
	 * `test1`
	 * ` `
	 * `test2`
	 * will return `["test1", "test2"]`
	 * @param path
	 * @return Array<String>
	 */
	@:noUsing public static function coolTextFile(path:String):Array<String>
	{
		var trim:String;
		return [for(line in Assets.getText(path).split("\n")) if ((trim = line.trim()) != "" && !trim.startsWith("#")) trim];
	}

	/**
	 * Returns an array of number from min to max. Equivalent of `[for (i in min...max) i]`.
	 * @param max Max value
	 * @param min Minimal value (0)
	 * @return Array<Int> Final array
	 */
	@:noUsing public static inline function numberArray(max:Int, ?min:Int = 0):Array<Int>
	{
		return [for (i in min...max) i];
	}

	/**
	 * Switches frames from 2 FlxAnimations.
	 * @param anim1 First animation
	 * @param anim2 Second animation
	 */
	@:noUsing public static function switchAnimFrames(anim1:FlxAnimation, anim2:FlxAnimation) {
		if (anim1 == null || anim2 == null) return;
		var old = anim1.frames;
		anim1.frames = anim2.frames;
		anim2.frames = old;
	}

	/**
	 * Allows you to set a graphic size (ex: 150x150), with proper hitbox without a stretched sprite.
	 * @param sprite Sprite to apply the new graphic size to
	 * @param width Width
	 * @param height Height
	 * @param fill Whenever the sprite should fill instead of shrinking (true)
	 * @param maxScale Maximum scale (0 / none)
	 */
	public static inline function setUnstretchedGraphicSize(sprite:FlxSprite, width:Int, height:Int, fill:Bool = true, maxScale:Float = 0) {
		sprite.setGraphicSize(width, height);
		sprite.updateHitbox();
		var nScale = (fill ? Math.max : Math.min)(sprite.scale.x, sprite.scale.y);
		if (maxScale > 0 && nScale > maxScale) nScale = maxScale;
		sprite.scale.set(nScale, nScale);
	}

	/**
	 * Returns a simple string representation of a FlxKey. Used in Controls options.
	 * @param key Key
	 * @return Simple representation
	 */
	public static inline function keyToString(key:Null<FlxKey>):String {
		return switch(key) {
			case null | 0 | NONE:	"---";
			case LEFT: 				"←";
			case DOWN: 				"↓";
			case UP: 				"↑";
			case RIGHT:				"→";
			case ESCAPE:			"ESC";
			case BACKSPACE:			"[←]";
			case NUMPADZERO:		"#0";
			case NUMPADONE:			"#1";
			case NUMPADTWO:			"#2";
			case NUMPADTHREE:		"#3";
			case NUMPADFOUR:		"#4";
			case NUMPADFIVE:		"#5";
			case NUMPADSIX:			"#6";
			case NUMPADSEVEN:		"#7";
			case NUMPADEIGHT:		"#8";
			case NUMPADNINE:		"#9";
			case NUMPADPLUS:		"#+";
			case NUMPADMINUS:		"#-";
			case NUMPADPERIOD:		"#.";
			case ZERO:				"0";
			case ONE:				"1";
			case TWO:				"2";
			case THREE:				"3";
			case FOUR:				"4";
			case FIVE:				"5";
			case SIX:				"6";
			case SEVEN:				"7";
			case EIGHT:				"8";
			case NINE:				"9";
			case PERIOD:			".";
			default:				key.toString();
		}
	}

	/**
	 * Centers an object in a camera's field, basically `screenCenter()` but `camera.width` and `camera.height` are used instead of `FlxG.width` and `FlxG.height`.
	 * @param obj Sprite to center
	 * @param cam Camera
	 * @param axes Axes (XY)
	 */
	public static inline function cameraCenter(obj:FlxObject, cam:FlxCamera, axes:FlxAxes = XY) {
		switch(axes) {
			case XY:
				obj.setPosition((cam.width - obj.width) / 2, (cam.height - obj.height) / 2);
			case X:
				obj.x = (cam.width - obj.width) / 2;
			case Y:
				obj.y = (cam.height - obj.height) / 2;
			case NONE:

		}
	}

	/**
	 * Equivalent of `setGraphicSize`, except that it can accept floats and automatically updates the hitbox.
	 * @param sprite Sprite to set the size of
	 * @param width Width
	 * @param height Height
	 */
	public static inline function setSpriteSize(sprite:FlxSprite, width:Float, height:Float) {
		sprite.scale.set(width / sprite.frameWidth, height / sprite.frameHeight);
		sprite.updateHitbox();
	}

	/**
	 * Gets an XML attribute from an `Access` abstract, without throwing an exception if invalid.
	 * Example: `xml.getAtt("test").getDefault("Hello, World!");`
	 * @param xml XML to get the attribute from
	 * @param name Name of the attribute
	 */
	public static inline function getAtt(xml:Access, name:String) {
		if (!xml.has.resolve(name)) return null;
		return xml.att.resolve(name);
	}

	/**
	 * Loads an animated graphic, and automatically animates it.
	 * @param spr Sprite to load the graphic for
	 * @param path Path to the graphic
	 */
	public static function loadAnimatedGraphic(spr:FlxSprite, path:String) {
		spr.frames = Paths.getFrames(path, true);

		if (spr.frames != null && spr.frames.frames != null) {
			spr.animation.add("idle", [for(i in 0...spr.frames.frames.length) i], 24, true);
			spr.animation.play("idle");
		}

		return spr;
	}

	/**
	 * Copies a color transform from color1 to color2
	 * @param color1 Color transform to copy to
	 * @param color2 Color transform to copy from
	 */
	public static inline function copyColorTransform(color1:ColorTransform, color2:ColorTransform) {
		color1.alphaMultiplier 	= color2.alphaMultiplier;
		color1.alphaOffset 		= color2.alphaOffset;
		color1.blueMultiplier 	= color2.blueMultiplier;
		color1.blueOffset 		= color2.blueOffset;
		color1.greenMultiplier 	= color2.greenMultiplier;
		color1.greenOffset 		= color2.greenOffset;
		color1.redMultiplier 	= color2.redMultiplier;
		color1.redOffset 		= color2.redOffset;
	}

	/**
	 * Resets an FlxSprite
	 * @param spr Sprite to reset
	 * @param x New X position
	 * @param y New Y position
	 */
	public static function resetSprite(spr:FlxSprite, x:Float, y:Float) {
		spr.reset(x, y);
		spr.alpha = 1;
		spr.visible = true;
		spr.active = true;
		spr.acceleration.set();
		spr.velocity.set();
		spr.drag.set();
		spr.antialiasing = FlxSprite.defaultAntialiasing;
		spr.frameOffset.set();
		FlxTween.cancelTweensOf(spr);
	}

	/**
	 * Gets the macro class created by hscript-improved for an abstract / enum
	 */
	@:noUsing public static inline function getMacroAbstractClass(className:String) {
		return Type.resolveClass('${className}_HSC');
	}

	/**
	 * Basically indexOf, but starts from the end.
	 * @param array Array to scan
	 * @param element Element
	 * @return Index, or -1 if unsuccessful.
	 */
	public static inline function indexOfFromLast<T>(array:Array<T>, element:T):Int {
		var i = array.length - 1;
		while(i >= 0) {
			if (array[i] == element)
				break;
			i--;
		}
		return i;
	}

	/**
	 * Clears the content of an array
	 */
	public static inline function clear<T>(array:Array<T>):Array<T> {
		// while(array.length > 0)
		// 	array.shift();
		array.resize(0);
		return array;
	}

	/**
	 * Push an entire group into an array.
	 * @param array Array to push the group into
	 * @param ...args Group entries
	 * @return Array<T>
	 */
	public static inline function pushGroup<T>(array:Array<T>, ...args:T):Array<T> {
		for(a in args)
			array.push(a);
		return array;
	}

	/**
	 * Opens an URL in the browser.
	 * @param url
	 */
	@:noUsing public static inline function openURL(url:String) {
		#if linux
		Sys.command('/usr/bin/xdg-open', [url, "&"]);
		#else
		FlxG.openURL(url);
		#end
	}

	/**
	 * Converts a timestamp to a readable format such as `01:22` (`mm:ss`)
	 */
	public static inline function timeToStr(time:Float)
		return '${Std.string(Std.int(time / 60000)).addZeros(2)}:${Std.string(Std.int(time / 1000) % 60).addZeros(2)}.${Std.string(Std.int(time % 1000)).addZeros(3)}';

	/**
	 * Stops a sound, set its time to 0 then play it again.
	 * @param sound Sound to replay.
	 */
	public static inline function replay(sound:FlxSound) {
		sound.stop();
		sound.time = 0;
		sound.play();
	}

	/**
	 * Equivalent of `Math.max`, except doesn't require a Int -> Float -> Int conversion.
	 * @param p1
	 * @param p2
	 * @return return p1 < p2 ? p2 : p1
	 */
	@:noUsing public static inline function maxInt(p1:Int, p2:Int)
		return p1 < p2 ? p2 : p1;

	/**
	 * Equivalent of `Math.floor`, except doesn't require a Int -> Float -> Int conversion.
	 * @param e Value to get the floor of.
	 */
	public static inline function floorInt(e:Float) {
		var r = Std.int(e);
		if (e < 0 && r != e)
			r--;
		return r;
	}

	@:noUsing public static inline function quantize(Value:Float, Quant:Float) {
		return Math.fround(Value * Quant) / Quant;
	}

	/**
	 * Sets a SoundFrontEnd's music to a FlxSound.
	 * Example: `FlxG.sound.setMusic(music);`
	 * @param frontEnd SoundFrontEnd to set the music of
	 * @param music Music
	 */
	public static inline function setMusic(frontEnd:SoundFrontEnd, music:FlxSound) {
		if (frontEnd.music != null)
			@:privateAccess frontEnd.destroySound(frontEnd.music);
		frontEnd.list.remove(music);
		frontEnd.music = music;
	}

	public static inline function flxeaseFromString(mainEase:String, suffix:String)
		return Reflect.field(FlxEase, mainEase + (mainEase == "linear" ? "" : suffix));
}

/**
 * SFXs to play using `playMenuSFX`.
 */
enum abstract CoolSfx(Int) from Int {
	var SCROLL = 0;
	var CONFIRM = 1;
	var CANCEL = 2;
	var CHECKED = 3;
	var UNCHECKED = 4;
	var WARNING = 5;
}