package funkin.editors.ui;

import flixel.util.FlxDestroyUtil;
import flixel.math.FlxRect;

@:allow(funkin.editors.ui.UIState)
class UISprite extends FlxSprite {
    public var members:Array<FlxBasic> = [];

    private var __lastDrawCameras:Array<FlxCamera> = [];
    private var __rect:FlxRect = new FlxRect();

    private var __oldDefCams:Array<FlxCamera>;

    var hovered:Bool = false;
    var pressed:Bool = false;

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
        
        hovered = false;
        pressed = false;
    }

    public override function draw() {
        drawSuper();
        drawMembers();
    }

    public function drawSuper() {
        super.draw();
        __lastDrawCameras = [for(c in cameras) c];
    }

    public function drawMembers() {
        
        @:privateAccess {
            __oldDefCams = FlxCamera._defaultCameras;
            FlxCamera._defaultCameras = cameras;

            for(m in members)
                m.draw();
            
            FlxCamera._defaultCameras = __oldDefCams;
        }
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
        hovered = true;
        if (FlxG.mouse.pressed)
            pressed = true;
    }
}