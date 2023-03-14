package funkin.editors.ui;

import flixel.util.FlxDestroyUtil;
import flixel.math.FlxRect;

@:allow(funkin.editors.ui.UIState)
class UISprite extends FlxSprite {
    public var members:Array<FlxBasic> = [];

    private var __lastDrawCameras:Array<FlxCamera> = [];
    private var __rect:FlxRect = new FlxRect();

    private var __oldDefCams:Array<FlxCamera>;

    public override function update(elapsed:Float) {
        super.update(elapsed);
        updateButton();

        @:privateAccess {
            __oldDefCams = FlxCamera._defaultCameras;
            FlxCamera._defaultCameras = cameras;

            for(m in members)
                m.update(elapsed);

            FlxCamera._defaultCameras = __oldDefCams;
        }
    }

    public override function draw() {
        super.draw();
        
        @:privateAccess {
            __oldDefCams = FlxCamera._defaultCameras;
            FlxCamera._defaultCameras = cameras;

            for(m in members)
                m.draw();
            
            FlxCamera._defaultCameras = __oldDefCams;
        }
        __lastDrawCameras = [for(c in cameras) c];
    }

    
    public override function destroy() {
        super.destroy();
        members = FlxDestroyUtil.destroyArray(members);
    }

    public function updateButton() {
        UIState.state.updateButtonHandler(this, onHovered);
    }

    /**
     * Called whenever the sprite is being hovered by the mouse.
     */
    public function onHovered() {

    }
}