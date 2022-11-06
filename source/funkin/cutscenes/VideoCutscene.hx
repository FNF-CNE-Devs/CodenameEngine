package funkin.cutscenes;

import flixel.FlxSprite;
import flixel.FlxG;
import flixel.FlxCamera;
import openfl.utils.Assets;

class VideoCutscene extends Cutscene {
    var path:String;
    var localPath:String;

    var video:MP4Handler;
    var videoSprite:FlxSprite;
    var cutsceneCamera:FlxCamera;
    public function new(path:String) {
        super();
        localPath = Assets.getPath(this.path = path);
    }

    public override function create() {
        super.create();
        
        cutsceneCamera = new FlxCamera();
        cutsceneCamera.bgColor = 0;
        FlxG.cameras.add(cutsceneCamera, false);
        
        video = new MP4Handler();
        video.finishCallback = close;
        video.canvasWidth = cutsceneCamera.width;
        video.canvasHeight = cutsceneCamera.height;

        videoSprite = new FlxSprite();
        videoSprite.cameras = [cutsceneCamera];
        videoSprite.antialiasing = true;
        add(videoSprite);
        
        video.playMP4(localPath, false, videoSprite);

        cameras = [cutsceneCamera];
    }

    public override function update(elapsed:Float) {
        super.update(elapsed);
        // video.se
        // video.setUnstretchedGraphicSize(FlxG.width, FlxG.height, false);
        // trace(video);
        // trace(video.getScreenBounds(null, cutsceneCamera));
    }
    public override function destroy() {
        FlxG.cameras.remove(camera, true);
        super.destroy();
    }
}