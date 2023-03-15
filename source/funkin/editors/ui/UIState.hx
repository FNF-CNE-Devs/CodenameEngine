package funkin.editors.ui;

import flixel.math.FlxPoint;
import flixel.math.FlxRect;

class UIState extends MusicBeatState {
    public static var state(get, null):UIState;

    public var buttonHandler:Void->Void = null;

    private var __rect:FlxRect;
    private var __mousePos:FlxPoint;

    private inline static function get_state()
        return FlxG.state is UIState ? cast FlxG.state : null;

    public override function create() {
        __rect = new FlxRect();
        __mousePos = FlxPoint.get();
        super.create();
    }

    public function updateButtonHandler(spr:UISprite, buttonHandler:Void->Void) {
        spr.__rect.x = spr.x;
        spr.__rect.y = spr.y;
        spr.__rect.width = spr.width;
        spr.__rect.height = spr.height;
        updateRectButtonHandler(spr, spr.__rect, buttonHandler);
    }

    public function updateRectButtonHandler(spr:UISprite, rect:FlxRect, buttonHandler:Void->Void) {
        var pos = FlxG.mouse.getScreenPosition(camera);
        for(camera in spr.__lastDrawCameras) {
            __rect.x = rect.x;
            __rect.y = rect.y;
            __rect.width = rect.width;
            __rect.height = rect.height;
            
            __rect.x -= camera.scroll.x * spr.scrollFactor.x;
            __rect.y -= camera.scroll.y * spr.scrollFactor.y;
            
            if (((pos.x > __rect.x) && (pos.x < __rect.x + rect.width)) && ((pos.y > __rect.y) && (pos.y < __rect.y + __rect.height))) {
                this.buttonHandler = buttonHandler;
                return;
            }
        }
    }

    public override function update(elapsed:Float) {
        super.update(elapsed);

        if (buttonHandler != null) {
            buttonHandler();
            buttonHandler = null;
        }
    }

    public override function destroy() {
        super.destroy();
        __mousePos.put();
    }
}