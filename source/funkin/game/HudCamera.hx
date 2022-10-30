package funkin.game;

import flixel.FlxCamera;

import lime.app.Application;
import flixel.graphics.tile.FlxGraphicsShader;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.DisplayObject;
import flash.display.Graphics;
import flash.display.Sprite;
import flash.geom.ColorTransform;
import flash.geom.Point;
import flash.geom.Rectangle;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxFrame;
import flixel.graphics.tile.FlxDrawBaseItem;
import flixel.graphics.tile.FlxDrawTrianglesItem;
import flixel.math.FlxMath;
import flixel.math.FlxMatrix;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxAssets.FlxShader;
import flixel.util.FlxAxes;
import flixel.util.FlxColor;
import flixel.util.FlxDestroyUtil;
import flixel.util.FlxSpriteUtil;
import openfl.display.BlendMode;
import openfl.filters.BitmapFilter;
import openfl.filters.ShaderFilter;
import openfl.Vector;

class HudCamera extends FlxCamera {
    public var downscroll:Bool = false;
    public override function update(elapsed:Float) {
        super.update(elapsed);
        flipY = downscroll;
    }


    public override function drawPixels(?frame:FlxFrame, ?pixels:BitmapData, matrix:FlxMatrix, ?transform:ColorTransform, ?blend:BlendMode, ?smoothing:Bool = false,
        ?shader:FlxShader):Void
    {
        if (downscroll) {
            matrix.scale(1, -1);
            matrix.translate(0, height);
        }
        super.drawPixels(frame, pixels, matrix, transform, blend, smoothing, shader);
    }
}