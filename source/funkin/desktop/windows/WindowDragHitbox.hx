package funkin.desktop.windows;

import flixel.FlxObject;

class WindowDragHitbox extends FlxObject {
    public var parent:Window;

    public var left:Float;
    public var top:Float;
    public var right:Float;

    public var dragging:Bool = false;

    public function new(left:Float, top:Float, right:Float, height:Float) {
        x = left;
        y = top;
        this.left = left;
        this.top = top;
        this.right = right;
        this.height = height;
    }

    public override function get_width() {
        return parent.windowWidth - left - right;
    }

    public override function update(elapsed:Float) {
        super.update(elapsed);
        if (dragging) {
            if (DesktopMain.instance.mouseInput.justReleased)
                dragging = false;
            DesktopMain.instance.mouseInput.cancel();
        } else {
            if (FlxG.mouse.overlaps(this)) {
                if (DesktopMain.instance.mouseInput.justPressed) {
                    dragging = true;
                }
                DesktopMain.instance.mouseInput.cancel();
            }
        }
    }
}