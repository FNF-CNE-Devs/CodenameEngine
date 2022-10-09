package funkin.system;

import lime.utils.Assets;
import flixel.animation.FlxAnimation;
import flixel.util.FlxColor;
import flixel.math.FlxMath;
import flixel.FlxG;

using StringTools;

class CoolUtil
{
	public static var difficultyArray:Array<String> = ['EASY', "NORMAL", "HARD"];

	/**
	 * Returns `v` if not null, `defaultValue` otherwise.
	 * @param v The value
	 * @param defaultValue The default value
	 * @return T The return value
	 */
	public static function getDefault<T>(v:T, defaultValue:T):T {
		return v == null ? defaultValue : v;
	}

	public static function fpsLerp(v1:Float, v2:Float, ratio:Float):Float {
		return FlxMath.lerp(v1, v2, getFPSRatio(ratio));
	}
	/**
	 * Lerps from color1 into color2 in a cool way 😎
	 * @param color1 Color 1
	 * @param color2 Color 2
	 * @param ratio Ratio
	 * @param fpsSensitive Whenever the ratio should be case sentivive (adapted when game is running at 120 instead of 60)
	 */
	public static function lerpColor(color1:FlxColor, color2:FlxColor, ratio:Float, fpsSensitive:Bool = false) {
		var h1 = color1.hue;
		var s1 = color1.saturation;
		var b1 = color1.brightness;

		var h2 = color2.hue;
		var s2 = color2.saturation;
		var b2 = color2.brightness;

		if (!fpsSensitive)
			ratio = getFPSRatio(ratio);

		if (Math.abs(h1-h2) > 180) h1 += 360;

		if (Math.abs(h1 - h2) > 90 || s2 < 0.125 || s1 < 0.125) {
			// classic r,g,b lerp
			var r1 = color1.redFloat;
			var g1 = color1.greenFloat;
			var b1 = color1.blueFloat;

			var r2 = color2.redFloat;
			var g2 = color2.greenFloat;
			var b2 = color2.blueFloat;

			return FlxColor.fromRGBFloat(
				FlxMath.lerp(r1, r2, ratio),
				FlxMath.lerp(g1, g2, ratio),
				FlxMath.lerp(b1, b2, ratio));
		}


		return FlxColor.fromHSB(
			FlxMath.lerp(h1, h2, ratio),
			FlxMath.lerp(s1, s2, ratio),
			FlxMath.lerp(b1, b2, ratio));
	}

	/**
	 * Modifies a lerp ratio based on current FPS to keep a stable speed on higher framerate.
	 * @param ratio Ratio
	 * @return Float FPS-Modified Ratio
	 */
	public static function getFPSRatio(ratio:Float) {
		return FlxMath.bound(ratio * 60 * FlxG.elapsed, 0, 1);
	}
	/**
	 * Tries to get a color from a `Dynamic` variable.
	 * @param c `Dynamic` color.
	 * @return Null<FlxColor> The result color
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

	public static function difficultyString():String
	{
		return difficultyArray[PlayState.storyDifficulty];
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
}