package funkin.game;

import flixel.addons.transition.FlxTransitionableState;
import flixel.system.FlxSound;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSubState;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import funkin.menus.StoryMenuState;
import funkin.menus.FreeplayState;
import funkin.system.Conductor;

class GameOverSubstate extends MusicBeatSubstate
{
	var bf:Character;
	public var character:String;
	public var gameOverSong:String;
	var camFollow:FlxObject;

	var stageSuffix:String = "";

	var x:Float = 0;
	var y:Float = 0;

	public var lossSFX:FlxSound;

	public function new(x:Float, y:Float, character:String = "bf", gameOverSong:String = "gameOver") {
		super();
		this.x = x;
		this.y = y;
		this.character = character;
		this.gameOverSong = gameOverSong;
	}

	public override function create()
	{
		super.create();
		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		bf = new Character(x, y, character, true);
		add(bf);

		camFollow = new FlxObject(bf.getGraphicMidpoint().x, bf.getGraphicMidpoint().y, 1, 1);
		add(camFollow);
		FlxG.camera.target = camFollow;

		lossSFX = FlxG.sound.play(Paths.sound('fnf_loss_sfx' + stageSuffix));
		Conductor.changeBPM(100);

		bf.danceOnBeat = false;
		bf.playAnim('firstDeath');
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

			if (PlayState.isStoryMode)
				FlxG.switchState(new StoryMenuState());
			else
				FlxG.switchState(new FreeplayState());
		}

		if (!lossSFX.playing && (FlxG.sound.music == null || !FlxG.sound.music.playing))
			CoolUtil.playMusic(Paths.music(gameOverSong), 100);
	}

	override function beatHit(curBeat:Int)
	{
		super.beatHit(curBeat);
		if (!lossSFX.playing)
			bf.playAnim("deathLoop", DANCE);
	}

	var isEnding:Bool = false;

	function endBullshit():Void
	{
		if (!isEnding)
		{
			isEnding = true;
			bf.playAnim('deathConfirm', true);
			FlxG.sound.music.stop();
			FlxG.sound.play(Paths.music('gameOverEnd' + stageSuffix));
			new FlxTimer().start(0.7, function(tmr:FlxTimer)
			{
				FlxG.camera.fade(FlxColor.BLACK, 2, false, function()
				{
					FlxTransitionableState.skipNextTransOut = true;
					FlxG.switchState(new PlayState());
				});
			});
		}
	}
}
