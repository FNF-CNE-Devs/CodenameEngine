package funkin.desktop;

import flixel.util.FlxDestroyUtil.IFlxDestroyable;
import openfl.events.Event;
import lime.app.Application;
import lime.ui.Window;

class DesktopScreen implements IFlxDestroyable {
    public var cameras:Array<FlxCamera> = [];
    public var window:Window;

    public function new() {
        window = Application.current.createWindow({
            x: 0,
            y: 0,
            width: FlxG.width,
            height: FlxG.height
        });
        @:privateAccess
        Application.current.__addWindow(window);

        window.stage.addEventListener(Event.ENTER_FRAME, onFrameEnter);

        FlxG.signals.preDraw.add(__onPreDraw);
        FlxG.signals.postDraw.add(__onPostDraw);

        window.onClose.add(destroy);
    }

    public function addCamera(cam:FlxCamera) {
        cameras.push(cam);
        window.stage.addChild(cam.flashSprite);
    }

    private inline function __onPreDraw() {}
    private inline function __onPostDraw() {}

    private function onFrameEnter(event:Event) {
        try {
            @:privateAccess
            for(c in cameras)
                c.render();
        } catch(e) {
            trace(e.toString());
        }
    }

    public function destroy() {
        for(c in cameras)
            c.destroy();
        window.close();
    }
}