package funkin.desktop.windows;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;

class WindowDragHitbox extends FlxObject {
    public var parent:Window;

    public var left:Float;
    public var top:Float;
    public var right:Float;

    public var dragging:Bool = false;

    public var offset:FlxPoint;

    public function new(left:Float, top:Float, right:Float, height:Float) {
        super();
        x = left;
        y = top;
        this.left = left;
        this.top = top;
        this.right = right;
        this.height = height;
    }

    public override function get_width() {
        return parent.windowCaptionCamera.width - left - right;
    }

    public override function update(elapsed:Float) {
        super.update(elapsed);
        if (!parent.moveable || parent.maximized) {
            dragging = false;
            return;
        }
        if (dragging) {
            var screenPos = FlxG.mouse.getScreenPosition(FlxG.camera);
            screenPos.x = FlxMath.bound(screenPos.x, 0, FlxG.camera.width);
            screenPos.y = FlxMath.bound(screenPos.y, 0, FlxG.camera.height);

            if (DesktopMain.mouseInput.justReleased) {
                dragging = false;
                offset.put();
                return;
            }
            parent.move(screenPos.x + offset.x, screenPos.y + offset.y);
            DesktopMain.mouseInput.cancel();
        } else {
            if (DesktopMain.mouseInput.overlaps(this, camera)) {
                if (DesktopMain.mouseInput.justPressed) {
                    var screenPos = FlxG.mouse.getScreenPosition(FlxG.camera);
                    offset = FlxPoint.get(parent.content.winX - screenPos.x, parent.content.winY - screenPos.y);
                    dragging = true;
                } else if (DesktopMain.mouseInput.justPressedRight) {
                    var input = DesktopMain.mouseInput;
                    ContextMenu.open(input.screenPos.x, input.screenPos.y, [
                        {
                            name: "Close",
                            callback: function() {
                                parent.close();
                            }
                        }
                    ], function(i) {
                        trace(i);
                    });
                }
                DesktopMain.mouseInput.cancel();
            }
        }
    }

    override function destroy() {
        super.destroy();
        if (offset != null)
            offset.put();
    }
}