package funkin.editors.ui;

import flixel.sound.FlxSound;
import haxe.io.Bytes;
import lime.media.AudioBuffer;
import openfl.media.Sound;

class UIAudioPlayer extends UIButton {
	public var sound:FlxSound;
	public var bytes:Bytes;

	public var playingSprite:FlxSprite;
	public var timeText:UIText;

	public function new(x:Float, y:Float, bytes:Bytes) {
		sound = FlxG.sound.load(Sound.fromAudioBuffer(AudioBuffer.fromBytes(bytes)));

		super(x, y, "", function () {
			if (sound.playing) sound.pause();
			else sound.play();
		}, 58 - 18, 58 - 18);

		playingSprite = new FlxSprite(x + ((58 - 18)/2) - 8, y + ((58 - 18)/2) - 8).loadGraphic(Paths.image('editors/charter/audio-buttons'), true, 16, 16);
		playingSprite.animation.add("paused", [0]);
		playingSprite.animation.add("playing", [1]);
		playingSprite.antialiasing = false;
		playingSprite.updateHitbox();
		members.push(playingSprite);

	}

	public override function update(elapsed:Float) {
		super.update(elapsed);

		if (sound != null)
			playingSprite.animation.play(sound.playing ? "playing" : "paused");
	}

	public override function destroy() {
		super.destroy();

		sound.stop();
		@:privateAccess sound.reset(); 
		bytes = null;
	}
}