package funkin.editors.ui;

import flixel.util.FlxColor;
import flixel.ui.FlxBar;
import openfl.geom.Rectangle;
import flixel.sound.FlxSound;
import haxe.io.Bytes;
import lime.media.AudioBuffer;
import openfl.media.Sound;
import flixel.util.FlxStringUtil;

using flixel.util.FlxSpriteUtil;

class UIAudioPlayer extends UIButton {
	public var sound:FlxSound;
	public var bytes:Bytes;

	public var playingSprite:FlxSprite;
	public var timeBar:FlxBar;
	public var timeText:UIText;

	public var timeBarSpr:UISprite; // VISUAL FEEDBACK !11!11!

	public function new(x:Float, y:Float, bytes:Bytes) {
		sound = FlxG.sound.load(Sound.fromAudioBuffer(AudioBuffer.fromBytes(bytes)));

		super(x, y, "", function () {
			if (sound.playing) sound.pause();
			else sound.play(false, sound.time);
		}, 58 - 16, 58 - 16);
		trace(x,y);

		playingSprite = new FlxSprite(x + ((58 - 16)/2) - 8, y + ((58 - 16)/2) - 8).loadGraphic(Paths.image('editors/charter/audio-buttons'), true, 16, 16);
		playingSprite.animation.add("paused", [0]);
		playingSprite.animation.add("playing", [1]);
		playingSprite.antialiasing = false;
		playingSprite.updateHitbox();
		members.push(playingSprite);

		timeText = new UIText(x + bWidth + 8, y + 4, 0, "", 12);
		timeText.alignment = RIGHT;
		members.push(timeText);

		timeBar = new FlxBar(x + bWidth + 8, y + (58 - 16) - ((58 - 16)/3) - 4, LEFT_TO_RIGHT, 202, Std.int((58 - 16)/3), sound, "time", 0, sound.length);
		timeBar.createImageBar(Paths.image('editors/charter/audio-time-empty'), Paths.image('editors/charter/audio-time-full'));
		timeBar.numDivisions = timeBar.barWidth;
		members.push(timeBar);

		timeBarSpr = cast new UISprite(timeBar.x, timeBar.y).makeGraphic(timeBar.barWidth, timeBar.barHeight, 0xFFFFFF);
		timeBarSpr.alpha = 0;
		members.push(timeBarSpr);
	}

	public var dragging:Bool = false;
	public var wasPlaying:Bool = false;

	public override function update(elapsed:Float) {
		super.update(elapsed);

		if (sound != null) {
			playingSprite.animation.play(sound.playing ? "playing" : "paused");
			timeText.text = '${FlxStringUtil.formatTime(sound.time/1000, true)} / ${FlxStringUtil.formatTime(sound.length/1000)}';
		}

		var mousePos = FlxG.mouse.getScreenPosition(__lastDrawCameras[0], FlxPoint.get());
		var spritePos:FlxPoint = timeBar.getScreenPosition(FlxPoint.get(), __lastDrawCameras[0]);

		if (((mousePos.x > (spritePos.x)) && (mousePos.x < (spritePos.x) + timeBar.barWidth)) 
			&& ((mousePos.y > (spritePos.y)) && (mousePos.y < (spritePos.y) + timeBar.barHeight))) {
			timeBarSpr.cursor = BUTTON;
			timeBarSpr.alpha = 0.3;
			if (FlxG.mouse.justPressed) {
				dragging = true;
				wasPlaying = sound.playing;
			}

			if (FlxG.mouse.pressed && dragging) {
				if (sound.playing) sound.pause();
				sound.time = FlxMath.remapToRange(mousePos.x - spritePos.x, 0, timeBar.barWidth, 0, sound.length);
			}
		} else {
			timeBarSpr.cursor = ARROW;
			timeBarSpr.alpha = 0;
		}

		if (FlxG.mouse.released && dragging && wasPlaying) {
			sound.play(dragging = wasPlaying = false, sound.time);
		}
	}

	public override function destroy() {
		super.destroy();

		sound.stop();
		@:privateAccess sound.reset(); 
		bytes = null;
	}
}