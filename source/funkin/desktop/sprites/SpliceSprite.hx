package funkin.desktop.sprites;

import openfl.display.BitmapData;
import openfl.geom.Rectangle;
import openfl.geom.Point;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.system.FlxAssets.FlxGraphicAsset;

class SpliceSprite extends FlxObject {
    public var topLeft:FlxSprite = new FlxSprite();
    public var left:FlxSprite = new FlxSprite();
    public var bottomLeft:FlxSprite = new FlxSprite();
    public var bottom:FlxSprite = new FlxSprite();
    public var bottomRight:FlxSprite = new FlxSprite();
    public var right:FlxSprite = new FlxSprite();
    public var topRight:FlxSprite = new FlxSprite();
    public var top:FlxSprite = new FlxSprite();
    public var middle:FlxSprite = new FlxSprite();

    public var __internalSprite:FlxSprite;
    public var slice:Array<Int> = [0, 0, 0, 0];

    public function new(spr:FlxGraphicAsset, x:Float, y:Float, width:Float, height:Float, left:Float = 5, top:Float = 5, bottom:Float = 5, right:Float = 5) {
        super();
        this.x = x;
        this.y = y;
        this.width = width;
        this.height = height;

        scrollFactor.set();

        __internalSprite = new FlxSprite(0, 0, spr);
        
        slice = [Std.int(left), Std.int(bottom), Std.int(top), Std.int(right)];
        // for(e in [topLeft, left, bottomLeft, bottom, bottomRight, right, topRight, top]) {
        //     e.loadGraphic(spr);
        // }
        updateRects();
    }

    public function updateRects() {
        var parts = [topLeft, left, bottomLeft, bottom, bottomRight, right, topRight, top];
        var _left:Int = slice[0];
        var _down:Int = slice[1];
        var _up:Int = slice[2];
        var _right:Int = slice[3];
        var _height:Int = __internalSprite.frameHeight;
        var _width:Int = __internalSprite.frameWidth;

        topLeft.pixels = new BitmapData(_left, _up, true, 0);
        left.pixels = new BitmapData(_left, _height - _up - _down, true, 0);
        bottomLeft.pixels = new BitmapData(_left, _down, true, 0);
        bottom.pixels = new BitmapData(_width - _left - _right, _down, true, 0);
        bottomRight.pixels = new BitmapData(_right, _down, true, 0);
        right.pixels = new BitmapData(_right, _height - _up - _down, true, 0);
        topRight.pixels = new BitmapData(_right, _up, true, 0);
        top.pixels = new BitmapData(_width - _left - _right, _up, true, 0);
        middle.pixels = new BitmapData(_width - _left - _right, _height - _up - _down, true, 0);


        for(e in parts) e.pixels.lock();

        var pos = new Point(0, 0);
        topLeft.pixels.copyPixels(__internalSprite.pixels, new Rectangle(0, 0, _left, _up), pos);
        left.pixels.copyPixels(__internalSprite.pixels, new Rectangle(0, _up, _left, _height - _up - _down), pos);
        bottomLeft.pixels.copyPixels(__internalSprite.pixels, new Rectangle(0, _height - _down, _left, _down), pos);
        bottom.pixels.copyPixels(__internalSprite.pixels, new Rectangle(_left, _height - _down, _width - _left - _right, _down), pos);
        bottomRight.pixels.copyPixels(__internalSprite.pixels, new Rectangle(_width - _right, _height - _down, _right, _down), pos);
        right.pixels.copyPixels(__internalSprite.pixels, new Rectangle(_width - _right, _up, _right, _height - _down - _up), pos);
        topRight.pixels.copyPixels(__internalSprite.pixels, new Rectangle(_width - _right, 0, _right, _up), pos);
        top.pixels.copyPixels(__internalSprite.pixels, new Rectangle(_left, 0, _width - _left - _right, _up), pos);
        middle.pixels.copyPixels(__internalSprite.pixels, new Rectangle(_left, _up, _width - _left - _right, _height - _up - _down), pos);

        for(e in parts) e.pixels.unlock();
    }

    public override function destroy() {
        for(e in [topLeft, left, bottomLeft, bottom, bottomRight, right, topRight, top, __internalSprite])
            e.destroy();
        super.destroy();
    }

    public function resize(width:Float, height:Float) {
        this.width = width;
        this.height = height;
    }

    public override function draw() {
        if (!visible) return;
        super.draw();
        var parts = [topLeft, left, bottomLeft, bottom, bottomRight, right, topRight, top, middle];

        var _left:Int = slice[0];
        var _down:Int = slice[1];
        var _up:Int = slice[2];
        var _right:Int = slice[3];

        // left
        topLeft.setPosition(x, y);
        left.setPosition(x, y + _up);
        left.setSpriteSize(_left, height - _up - _down);
        bottomLeft.setPosition(x, y + height - _down);
        
        // top
        top.setPosition(x + _left, y);
        top.setSpriteSize(width - _left - _right, _up);
        
        // bottom
        bottom.setPosition(x + _left, y + height - _down);
        bottom.setSpriteSize(width - _left - _right, _down);

        // right
        topRight.setPosition(x + (width - _right), y);
        right.setPosition(x + (width - _right), y + _up);
        right.setSpriteSize(_right, height - _up - _down);
        bottomRight.setPosition(x + (width - _right), y + height - _down);

        // middle by dj snake
        middle.setPosition(x + _left, y + _up);
        middle.setSpriteSize(width - _left - _right, height - _up - _down);

        for(e in parts) {
            e.cameras = cameras;
            e.scrollFactor.set(scrollFactor.x, scrollFactor.y);
            e.draw();
        }
    }

    public override function update(elapsed:Float) {
        super.update(elapsed);
        for(e in [topLeft, left, bottomLeft, bottom, bottomRight, right, topRight, top])
            e.update(elapsed);
    }
}