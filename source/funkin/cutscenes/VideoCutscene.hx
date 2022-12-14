package funkin.cutscenes;

import flixel.FlxSprite;
import flixel.FlxG;
import flixel.FlxCamera;
import openfl.utils.Assets;

class VideoCutscene extends Cutscene {
    var path:String;
    var localPath:String;

    #if VIDEO_CUTSCENES
    var video:MP4Handler;
    var videoSprite:FlxSprite;
    #end
    var cutsceneCamera:FlxCamera;
    
    public function new(path:String, callback:Void->Void) {
        super(callback);
        localPath = Assets.getPath(this.path = path);
    }

    public override function create() {
        super.create();
        
        cutsceneCamera = new FlxCamera();
        cutsceneCamera.bgColor = 0;
        FlxG.cameras.add(cutsceneCamera, false);
        
        #if VIDEO_CUTSCENES
        video = new MP4Handler();
        video.finishCallback = close;
        video.canvasWidth = cutsceneCamera.width;
        video.canvasHeight = cutsceneCamera.height;

        videoSprite = new FlxSprite();
        videoSprite.cameras = [cutsceneCamera];
        videoSprite.antialiasing = true;
        add(videoSprite);
        
        video.playMP4(localPath, false, videoSprite);
        #end

        cameras = [cutsceneCamera];
    }

    public override function update(elapsed:Float) {
        super.update(elapsed);
        #if !VIDEO_CUTSCENES
        close();
        #end
    }
    public override function destroy() {
        FlxG.cameras.remove(cutsceneCamera, true);
        super.destroy();
    }
}