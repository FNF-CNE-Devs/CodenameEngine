package funkin.cutscenes;

import flixel.addons.display.FlxBackdrop;
#if sys
import sys.io.File;
#end
import funkin.ui.FunkinText;


/**
 * Substate made for video cutscenes. To use it in a scripted cutscene, call `startVideo`.
 */
class VideoCutscene extends Cutscene {
	public static var curVideo:Int = 0;
	var path:String;
	var localPath:String;

	#if VIDEO_CUTSCENES
	var video:MP4Handler;
	var videoSprite:FlxSprite;
	#end
	var cutsceneCamera:FlxCamera;

	var text:FunkinText;
	var loadingBackdrop:FlxBackdrop;
	var videoReady:Bool = false;
	
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
		
		if (localPath.startsWith("[ZIP]")) {
			text = new FunkinText(10, 10, Std.int(FlxG.width / 2), "Loading video...");
			text.cameras = [cutsceneCamera];
			text.visible = false;
			@:privateAccess
			text.regenGraphic();
			add(text);

			loadingBackdrop = new FlxBackdrop(text.graphic, X);
			loadingBackdrop.y = FlxG.height - 20 - loadingBackdrop.height;
			loadingBackdrop.cameras = [cutsceneCamera];
			add(loadingBackdrop);

			// ZIP PATH: EXPORT
			// TODO: this but better and more ram friendly
			localPath = './.temp/video-${curVideo++}.mp4';
			Main.execAsync(function() {
				File.saveBytes(localPath, Assets.getBytes(path));
				videoReady = true;
			});
		} else {
			video.playMP4(localPath, false, videoSprite);
		}
		add(videoSprite);
		#end

		cameras = [cutsceneCamera];
	}

	public override function update(elapsed:Float) {
		super.update(elapsed);
		#if VIDEO_CUTSCENES
		if (videoReady) {
			videoReady = false;
			video.playMP4(localPath, false, videoSprite);
			if (loadingBackdrop != null)
				loadingBackdrop.visible = false;
		}
		if (loadingBackdrop != null) {
			loadingBackdrop.x -= elapsed * FlxG.width * 0.5;
		}
		#else
		close();
		#end
	}
	public override function destroy() {
		FlxG.cameras.remove(cutsceneCamera, true);
		super.destroy();
	}
}