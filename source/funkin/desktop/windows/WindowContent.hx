package funkin.desktop.windows;

import flixel.FlxBasic;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.FlxCamera;

class WindowContent extends WindowGroup<FlxBasic> {
    public var winX(default, set):Float = 0;
    public var winY(default, set):Float = 0;
    public var title(default, set):String = "Window";
    public var icon(default, set):String = 'flixel/images/logo/default.png';

    public var windowCamera:FlxCamera = null;
    public var parent:Window = null;

    public var width(default, set):Int = 0;
    public var height(default, set):Int = 0;

    private var __noParentUpdate:Bool = false;
    private function set_width(w:Int):Int {
        width = w;
        if (parent != null && !__noParentUpdate) {
            parent.windowWidth = w;
            if (!__noParentUpdate)
                parent.updateWindowFrame();
        }
        return width;
    }
    private function set_height(h:Int):Int {
        height = h;
        if (parent != null && !__noParentUpdate) {
            parent.windowHeight = h;
            if (!__noParentUpdate)
                parent.updateWindowFrame();
        }
        return height;
    }
    private function set_winX(v:Float):Float {
        winX = v;
        if (parent != null && !__noParentUpdate) parent.move(winX, winY);
        return winX;
    }

    private function set_title(text:String):String {
        title = text;
        if (parent != null && !__noParentUpdate) parent.changeCaption(title);
        return title;
    }

    private function set_icon(text:String):String {
        icon = text;
        if (parent != null && !__noParentUpdate) parent.loadIcon(icon);
        return icon;
    }
    private function set_winY(v:Float):Float {
        winY = v;
        if (parent != null && !__noParentUpdate) parent.move(winX, winY);
        return winY;
    }

    public function setSize(width:Int, height:Int) {
        __noParentUpdate = true;
        this.width = width;
        this.height = height;
        __noParentUpdate = false;
        if (parent != null) parent.updateWindowFrame();
    }

    public function new(caption:String, x:Float, y:Float, width:Int, height:Int) {
        super();
        this.title = caption;
        this.width = width;
        this.height = height;
        this.winX = x;
        this.winY = y;
        this.updateScrolls = false;
    }

    public function create() {

    }

    public function onWindowResize(width:Int, height:Int) {
        
    }
    
    public function onDesktopSizeChange(width:Int, height:Int) {
        
    }
}