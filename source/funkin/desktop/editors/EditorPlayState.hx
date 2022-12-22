package funkin.desktop.editors;

import flixel.FlxG;
import flixel.FlxCamera;
import flixel.math.FlxPoint;

class EditorPlayState extends WindowContent {
    var state:PlayState;

    public function new() {
        super("PlayState", 120, 120, 1280, 720);
        state = new PlayState();
    }
    public override function create() {
        super.create();

        beforeStateShit();
        state.camera = parent.windowCameras[0].camera;
        state.create();
        afterStateShit();

        parent.windowCameras[0].resizeScroll = false;
        parent.windowCameras.push(
            {
                camera: state.camHUD,
                width: 1280,
                height: 720,
                resizeScroll: true
            }
        );
        parent.move(winX, winY);
        parent.resize(1280, 720);
        beforeStateShit();
        state.createPost();
        afterStateShit();
    }
    var oldSize = FlxPoint.get(FlxG.width, FlxG.height);
    var oldCamList:Array<FlxCamera>;
    var oldCam:FlxCamera;
    
    public function beforeStateShit() {
        oldSize.set(FlxG.width, FlxG.height);
        @:privateAccess
        FlxG.width = 1280;
        @:privateAccess
        FlxG.height = 720;

        oldCamList = FlxG.cameras.list;
        oldCam = FlxG.camera;
        @:privateAccess
        FlxG.cameras.list = [for(e in parent.windowCameras) e.camera];
        FlxG.camera = parent.windowCameras[0].camera;
    }
    public function afterStateShit() {
        @:privateAccess
        FlxG.width = Std.int(oldSize.x);
        @:privateAccess
        FlxG.height = Std.int(oldSize.y);

        parent.windowCameras = [for(e in FlxG.cameras.list) {
            camera: e,
            width: 1280,
            height: 720,
            resizeScroll: false
        }];
        @:privateAccess
        FlxG.cameras.list = oldCamList;
        FlxG.camera = oldCam;

        oldCamList = null;
        oldCam = null;
    }

    public override function update(elapsed:Float) {
        beforeStateShit();
        super.update(elapsed);
        @:privateAccess
        FlxG.cameras.update(elapsed);
        state.tryUpdate(elapsed);
        afterStateShit();
    }

    public override function destroy() {
        beforeStateShit();
        super.destroy();
        state.destroy();
        afterStateShit();
    }

    public override function draw() {
        beforeStateShit();
        super.draw();
        state.draw();
        afterStateShit();
    }
}