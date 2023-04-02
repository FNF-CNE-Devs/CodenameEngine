package funkin.cutscenes;

import flixel.util.FlxColor;
import haxe.io.Path;
import flixel.addons.display.FlxBackdrop;
#if sys
import sys.io.File;
#end
import funkin.ui.FunkinText;
import haxe.xml.Access;


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

	var bg:FlxSprite;
	var subtitle:FunkinText;

	public var subtitles:Array<CutsceneSubtitle> = [];

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
		parseSubtitles();

		video = new MP4Handler();
		video.finishCallback = close;
		video.canvasWidth = cutsceneCamera.width;
		video.canvasHeight = cutsceneCamera.height;

		videoSprite = new FlxSprite();
		videoSprite.cameras = [cutsceneCamera];
		videoSprite.antialiasing = true;

		bg = new FlxSprite(0, FlxG.height * 0.85).makeGraphic(1, 1, 0xFF000000);
		bg.alpha = 0.5;
		bg.visible = false;

		subtitle = new FunkinText(0, FlxG.height * 0.875, 0, "", 20);
		subtitle.alignment = CENTER;
		subtitle.visible = false;

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
		add(bg);
		add(subtitle);
		#end

		cameras = [cutsceneCamera];
	}

	public function parseSubtitles() {
		var subtitlesPath = '${Path.withoutExtension(path)}.xml';
		trace(subtitlesPath);

		if (Assets.exists(subtitlesPath)) {
			// subtitles found
			var subtitleData:Access = null;
			try {
				subtitleData = new Access(Xml.parse(Assets.getText(subtitlesPath)));
			} catch(e) {
				Logs.trace('Subtitles XML couldn\'t be parsed: ${e}', ERROR, RED);
			}

			if (subtitleData != null) {
				// subtitles parsed correctly, cycling
				for(node in subtitleData.nodes.subtitles) {
					for(sNode in node.nodes.subtitle) {
						if (!sNode.has.time) continue;

						var timeSplit:Array<Null<Float>> = [for(e in sNode.att.time.split(":")) Std.parseFloat(e)];
						var multipliers:Array<Float> = [1, 60, 3600, 86400]; // no way a cutscene will last longer than days
						var time:Float = 0;

						for(k=>i in timeSplit) {
							var mul = multipliers[timeSplit.length - 1 - k];
							if (i != null)
								time += i * mul;
						}

						subtitles.push({
							subtitle: sNode.innerData,
							time: time * 1000,
							color: sNode.has.color ? CoolUtil.getColorFromDynamic(sNode.att.color).getDefault(0xFFFFFFFF) : 0xFFFFFFFF
						});
					}
				}
			}
		}

		trace(subtitles);
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
		@:privateAccess
		var time = video.bitmap.getTime();
		while (subtitles.length > 0 && subtitles[0].time < time)
			setSubtitle(subtitles.shift());

		if (loadingBackdrop != null) {
			loadingBackdrop.x -= elapsed * FlxG.width * 0.5;
		}
		#else
		close();
		#end
	}

	public function setSubtitle(sub:CutsceneSubtitle) {
		if (bg.visible = subtitle.visible = (sub.subtitle.length > 0)) {
			subtitle.text = sub.subtitle;
			subtitle.color = sub.color;
			subtitle.screenCenter(X);
			bg.scale.set(subtitle.width + 8, subtitle.height + 8);
			bg.updateHitbox();
			bg.setPosition(subtitle.x - 4, subtitle.y - 4);
		}
	}

	public override function destroy() {
		FlxG.cameras.remove(cutsceneCamera, true);
		super.destroy();
	}
}

typedef CutsceneSubtitle = {
	var time:Float; // time in ms
	var subtitle:String; // subtitle text
	var color:FlxColor;
}