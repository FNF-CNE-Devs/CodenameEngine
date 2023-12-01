package funkin.game;


import lime.app.Application;
import flixel.graphics.tile.FlxGraphicsShader;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.DisplayObject;
import openfl.display.Graphics;
import openfl.display.Sprite;
import openfl.geom.ColorTransform;
import openfl.geom.Point;
import openfl.geom.Rectangle;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxFrame;
import flixel.graphics.tile.FlxDrawBaseItem;
import flixel.graphics.tile.FlxDrawTrianglesItem;
import flixel.math.FlxMatrix;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxAssets.FlxShader;
import flixel.util.FlxAxes;
import flixel.util.FlxColor;
import flixel.util.FlxSpriteUtil;
import openfl.display.BlendMode;
import openfl.filters.BitmapFilter;
import openfl.filters.ShaderFilter;
import openfl.Vector;

class HudCamera extends FlxCamera {
	public var downscroll:Bool = false;
	//public override function update(elapsed:Float) {
	//	super.update(elapsed);
	//	// flipY = downscroll;
	//}


	// public override function drawPixels(?frame:FlxFrame, ?pixels:BitmapData, matrix:FlxMatrix, ?transform:ColorTransform, ?blend:BlendMode, ?smoothing:Bool = false,
	// 	?shader:FlxShader):Void
	// {
	// 	if (downscroll) {
	// 		matrix.scale(1, -1);
	// 		matrix.translate(0, height);
	// 	}
	// 	super.drawPixels(frame, pixels, matrix, transform, blend, smoothing, shader);
	// }


	public override function alterScreenPosition(spr:FlxObject, pos:FlxPoint) {
		if (downscroll) {
			pos.set(pos.x, height - pos.y - spr.height);
		}
		return pos;
	}
}