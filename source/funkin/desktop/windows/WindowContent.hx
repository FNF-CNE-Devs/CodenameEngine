package funkin.desktop.windows;

import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.FlxCamera;

class WindowContent extends FlxTypedGroup<FlxSprite> {
    public var winX(default, set):Float = 0;
    public var winY(default, set):Float = 0;
    public var title(default, set):String = "Window";

    public var windowCamera:FlxCamera = null;
    public var parent:Window = null;

    public var width:Int = 0;
    public var height:Int = 0;

    private function set_winX(v:Float):Float {
        winX = v;
        if (parent != null) parent.move(winX, winY);
        return winX;
    }

    private function set_title(text:String):String {
        title = text;
        if (parent != null) parent.changeCaption(title);
        return title;
    }
    private function set_winY(v:Float):Float {
        winY = v;
        if (parent != null) parent.move(winX, winY);
        return winY;
    }

    public function new(caption:String, x:Float, y:Float, width:Int, height:Int) {
        super();
        this.width = width;
        this.height = height;
        this.winX = x;
        this.winY = y;
    }

    public function create() {

    }
}