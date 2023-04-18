package funkin.backend.utils;

import openfl.display.BitmapData;
import flixel.util.FlxColor;

class BitmapUtil {
	/**
	 * Returns the most present color in a Bitmap.
	 * @param bmap Bitmap
	 * @return FlxColor Color that is the most present.
	 */
	public static function getMostPresentColor(bmap:BitmapData):FlxColor {
		// map containing all the colors and the number of times they've been assigned.
		var colorMap:Map<FlxColor, Float> = [];
		var color:FlxColor = 0;
		var fixedColor:FlxColor = 0;

		for(y in 0...bmap.height) {
			for(x in 0...bmap.width) {
				color = bmap.getPixel32(x, y);
				fixedColor = 0xFF000000 + (color % 0x1000000);
				if (colorMap[fixedColor] == null)
					colorMap[fixedColor] = 0;
				colorMap[fixedColor] += color.alphaFloat;
			}
		}

		var mostPresentColor:FlxColor = 0;
		var mostPresentColorCount:Float = -1;
		for(c=>n in colorMap) {
			if (n > mostPresentColorCount) {
				mostPresentColorCount = n;
				mostPresentColor = c;
			}
		}
		return mostPresentColor;
	}
	/**
	 * Returns the most present saturated color in a Bitmap.
	 * @param bmap Bitmap
	 * @return FlxColor Color that is the most present.
	 */
	public static function getMostPresentSaturatedColor(bmap:BitmapData):FlxColor {
		// map containing all the colors and the number of times they've been assigned.
		var colorMap:Map<FlxColor, Float> = [];
		var color:FlxColor = 0;
		var fixedColor:FlxColor = 0;

		for(y in 0...bmap.height) {
			for(x in 0...bmap.width) {
				color = bmap.getPixel32(x, y);
				fixedColor = 0xFF000000 + (color % 0x1000000);
				if (colorMap[fixedColor] == null)
					colorMap[fixedColor] = 0;
				colorMap[fixedColor] += color.alphaFloat * 0.33 + (0.67 * (color.saturation * (2 * (color.lightness > 0.5 ? 0.5 - (color.lightness) : color.lightness))));
			}
		}

		var mostPresentColor:FlxColor = 0;
		var mostPresentColorCount:Float = -1;
		for(c=>n in colorMap) {
			if (n > mostPresentColorCount) {
				mostPresentColorCount = n;
				mostPresentColor = c;
			}
		}
		return mostPresentColor;
	}
}