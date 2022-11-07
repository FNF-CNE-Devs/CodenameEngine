package funkin.system;

import animateatlas.AtlasFrameMaker;
import haxe.Json;
import funkin.menus.StoryMenuState.WeekData;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.graphics.FlxGraphic;
import haxe.io.Path;
import haxe.xml.Access;
import flixel.input.keyboard.FlxKey;
import lime.utils.Assets;
import flixel.animation.FlxAnimation;
import flixel.util.FlxColor;
import flixel.math.FlxMath;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxObject;
import flixel.FlxCamera;
import flixel.util.FlxAxes;
import flixel.graphics.frames.FlxFrame;
import flixel.graphics.frames.FlxFramesCollection;

using StringTools;

class CoolUtil
{
	/*
	 * Returns `v` if not null, `defaultValue` otherwise.
	 * @param v The value
	 * @param defaultValue The default value
	 * @return The return value
	 */
	public static function getDefault<T>(v:T, defaultValue:T):T {
		return (v == null || isNaN(v)) ? defaultValue : v;
	}

	public static function parseJson(assetPath:String) {
		return Json.parse(Assets.getText(assetPath));
	}

	public inline static function parseJsonString(str:String)
		return Json.parse(str);

	public static function isNaN(v:Dynamic) {
		if (v is Float || v is Int)
			return Math.isNaN(cast(v, Float));
		return false;
	}

	public static function setFieldDefault<T>(v:Dynamic, name:String, defaultValue:T):T {
		if (Reflect.hasField(v, name)) {
			var f:Null<Dynamic> = Reflect.field(v, name);
			if (f != null)
				return cast f;
		} 
		Reflect.setField(v, name, defaultValue);
		return defaultValue;
	}

	public static function addZeros(str:String, num:Int) {
		while(str.length < num) str = '0${str}';
		return str;
	}

	public static function getSizeString(size:UInt):String {
		var labels = ["B", "KB", "MB", "GB", "TB"];
		var rSize:Float = size;
		var label:Int = 0;
		while(rSize > 1024 && label < labels.length-1) {
			label++;
			rSize /= 1024;
		}
		return '${FlxMath.roundDecimal(rSize, 2)}${labels[label]}';
	}

	public static function fpsLerp(v1:Float, v2:Float, ratio:Float):Float {
		return FlxMath.lerp(v1, v2, getFPSRatio(ratio));
	}
	/**
	 * Lerps from color1 into color2 (Shortcut to `FlxColor.interpolate`)
	 * @param color1 Color 1
	 * @param color2 Color 2
	 * @param ratio Ratio
	 * @param fpsSensitive Whenever the ratio should be case sentivive (adapted when game is running at 120 instead of 60)
	 */
	public static function lerpColor(color1:FlxColor, color2:FlxColor, ratio:Float, fpsSensitive:Bool = false) {
		if (!fpsSensitive)
			ratio = getFPSRatio(ratio);
		return FlxColor.interpolate(color1, color2, ratio);
	}

	/**
	 * Modifies a lerp ratio based on current FPS to keep a stable speed on higher framerate.
	 * @param ratio Ratio
	 * @return FPS-Modified Ratio
	 */
	public static function getFPSRatio(ratio:Float):Float {
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
						case 0:		r = Std.int(e);
						case 1:		g = Std.int(e);
						case 2:		b = Std.int(e);
						case 3:		a = Std.int(e);
					}
				}
			}
			return FlxColor.fromRGB(r, g, b, a);
		}
		return null;
	}

	public static function playMenuSong(fadeIn:Bool = false) {
		if (FlxG.sound.music == null || !FlxG.sound.music.playing)
		{
			Conductor.reset();

			// TODO: bpm from config
			Conductor.changeBPM(102);
			FlxG.sound.playMusic(Paths.music('freakyMenu'), fadeIn ? 0 : 1);
			if (fadeIn)
				FlxG.sound.music.fadeIn(4, 0, 0.7);
		}
	}
	/**
	 * Plays a specified Menu SFX.
	 * @param menuSFX Menu SFX to play
	 * @param volume At which volume it should play
	 */
	public static function playMenuSFX(menuSFX:Int = 0, volume:Float = 1) {
		FlxG.sound.play(Paths.sound(switch(menuSFX) {
			case 1:		'menu/confirm';
			case 2:		'menu/cancel';
			default: 	'menu/scroll';
		}), volume);
	}

	public static function coolTextFile(path:String):Array<String>
	{
		return [for(e in Assets.getText(path).trim().split('\n')) e.trim()];
	}

	public static function numberArray(max:Int, ?min = 0):Array<Int>
	{
		return [for (i in min...max) i];
	}

	public static function switchAnimFrames(anim1:FlxAnimation, anim2:FlxAnimation) {
		if (anim1 == null || anim2 == null) return;
		var old = anim1.frames;
		anim1.frames = anim2.frames;
		anim2.frames = old;
	}

	public static function setUnstretchedGraphicSize(sprite:FlxSprite, width:Int, height:Int, fill:Bool = true, maxScale:Float = 0) {
		sprite.setGraphicSize(width, height);
		sprite.updateHitbox();
		var nScale = (fill ? Math.max : Math.min)(sprite.scale.x, sprite.scale.y);
		if (maxScale > 0 && nScale > maxScale) nScale = maxScale;
		sprite.scale.set(nScale, nScale);
	}

	public static function keyToString(key:Null<FlxKey>):String {
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

	public static function cameraCenter(obj:FlxObject, cam:FlxCamera, axes:FlxAxes = XY) {
		switch(axes) {
			case XY:
				obj.setPosition((cam.width - obj.width) / 2, (cam.height - obj.height) / 2);
			case X:
				obj.x = (cam.width - obj.width) / 2;
			case Y:
				obj.y = (cam.height - obj.height) / 2;
		}
	}

	public static function loadWeek(weekData:WeekData, difficulty:String = "normal") {
        PlayState.storyWeek = weekData;
        PlayState.storyPlaylist = [for(e in weekData.songs) e.name];
        PlayState.isStoryMode = true;
		PlayState.campaignScore = 0;
		__loadSong(PlayState.storyPlaylist[0], difficulty);
	}
	public static function loadSong(name:String, difficulty:String = "normal") {
		PlayState.campaignScore = 0;
		PlayState.isStoryMode = false;
		__loadSong(name, difficulty);
	}
	public static function __loadSong(name:String, difficulty:String) {
		PlayState.difficulty = difficulty;
		PlayState.SONG = Song.loadFromJson(name, difficulty);
	}
	public static function setSpriteSize(sprite:FlxSprite, width:Float, height:Float) {
		sprite.scale.set(width / sprite.frameWidth, height / sprite.frameHeight);
		sprite.updateHitbox();
	}

	public static function getAtt(xml:Access, name:String) {
		if (!xml.has.resolve(name)) return null;
		return xml.att.resolve(name);
	}

	/**
	 * Returns last member of array
	 */
	public static function last<T>(array:Array<T>):T {
		return array[array.length-1];
	}

	public static function loadFrames(path:String, Unique:Bool = false, Key:String = null):FlxFramesCollection {
		var noExt = Path.withoutExtension(path);

		if (Assets.exists('$noExt/Animation.json')
		&& Assets.exists('$noExt/spritemap.json')
		&& Assets.exists('$noExt/spritemap.png')) {
			// TODO: Credit Smokey555!!
			return AtlasFrameMaker.construct(noExt);
		if (Assets.exists('$noExt.xml')) {
			return Paths.getSparrowAtlasAlt(noExt);
		} else if (Assets.exists('$noExt.txt')) {
			return Paths.getPackerAtlasAlt(noExt);
		}

		var graph:FlxGraphic = FlxG.bitmap.add(path, Unique, Key);
		if (graph == null)
			return null;
		return graph.imageFrame;
	}
	
	public static function loadAnimatedGraphic(spr:FlxSprite, path:String) {
		spr.frames = loadFrames(path);
		
		if (spr.frames != null && spr.frames.frames != null) {
			spr.animation.add("idle", [for(i in 0...spr.frames.frames.length) i], 24, true);
			spr.animation.play("idle");
		}
	}
}