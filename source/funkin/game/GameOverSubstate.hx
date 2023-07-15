package funkin.game;

import flixel.addons.transition.FlxTransitionableState;
import flixel.sound.FlxSound;
import flixel.FlxSubState;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import funkin.menus.StoryMenuState;
import funkin.menus.FreeplayState;
import funkin.backend.system.Conductor;

class GameOverSubstate extends MusicBeatSubstate
{
	var character:Character;
	public var characterName:String;
	public var gameOverSong:String;
	public var lossSFXName:String;
	public var retrySFX:String;
	public var player:Bool;
	var camFollow:FlxObject;

	var x:Float = 0;
	var y:Float = 0;

	public var lossSFX:FlxSound;

	public function new(x:Float, y:Float, character:String = "bf-dead", player:Bool = true, gameOverSong:String = "gameOver", lossSFX:String = "gameOverSFX", retrySFX:String = "gameOverEnd") {
		super();
		this.x = x;
		this.y = y;
		this.characterName = character;
		this.player = player;
		this.gameOverSong = gameOverSong;
		this.lossSFXName = lossSFX;
		this.retrySFX = retrySFX;
	}

	public override function create()
	{
		super.create();
		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		character = new Character(x, y, characterName, player);
		character.danceOnBeat = false;
		character.playAnim('firstDeath');
		add(character);

		var camPos = character.getCameraPosition();
		camFollow = new FlxObject(camPos.x, camPos.y, 1, 1);
		add(camFollow);
		FlxG.camera.target = camFollow;

		lossSFX = FlxG.sound.play(Paths.sound(lossSFXName));
		Conductor.changeBPM(100);

		DiscordUtil.changePresence('Game Over', PlayState.SONG.meta.displayName + " (" + PlayState.difficulty + ")");
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (controls.ACCEPT)
		{
			endBullshit();
		}

		if (controls.BACK)
		{
			if (FlxG.sound.music != null)
				FlxG.sound.music.stop();
			FlxG.sound.music = null;

			if (PlayState.isStoryMode)
				FlxG.switchState(new StoryMenuState());
			else
				FlxG.switchState(new FreeplayState());
		}

		if (!isEnding && ((!lossSFX.playing) || (character.getAnimName() == "firstDeath" && character.isAnimFinished())) && (FlxG.sound.music == null || !FlxG.sound.music.playing)) {
			CoolUtil.playMusic(Paths.music(gameOverSong), false, 1, true, 100);
			beatHit(0);
		}
	}

	override function beatHit(curBeat:Int)
	{
		super.beatHit(curBeat);
		if (FlxG.sound.music != null && FlxG.sound.music.playing)
			character.playAnim("deathLoop", true, DANCE);
	}

	var isEnding:Bool = false;

	function endBullshit():Void
	{
		if (!isEnding)
		{
			isEnding = true;
			character.playAnim('deathConfirm', true);
			if (FlxG.sound.music != null)
				FlxG.sound.music.stop();
			FlxG.sound.music = null;

			var sound = FlxG.sound.play(Paths.sound(retrySFX));

			var secsLength:Float = sound.length / 1000;
			var waitTime = 0.7;
			var fadeOutTime = secsLength - 0.7;

			if (fadeOutTime < 0.5) {
				fadeOutTime = secsLength;
				waitTime = 0;
			}

			new FlxTimer().start(waitTime, function(tmr:FlxTimer)
			{
				FlxG.camera.fade(FlxColor.BLACK, fadeOutTime, false, function()
				{
					MusicBeatState.skipTransOut = true;
					FlxG.switchState(new PlayState());
				});
			});
		}
	}
}
