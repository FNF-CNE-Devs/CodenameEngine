package funkin.menus;

import funkin.options.OptionsMenu;
import flixel.FlxCamera;
import funkin.scripting.events.PauseCreationEvent;
import funkin.scripting.events.NameEvent;
import funkin.scripting.Script;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.keyboard.FlxKey;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import funkin.ui.Alphabet;
import funkin.options.keybinds.KeybindsOptions;
import funkin.menus.StoryMenuState;

class PauseSubState extends MusicBeatSubstate
{
	public static var script:String = "";

	var grpMenuShit:FlxTypedGroup<Alphabet>;

	var menuItems:Array<String> = ['Resume', 'Restart Song', 'Change Controls', 'Options','Exit to menu'];
	var curSelected:Int = 0;

	var pauseMusic:FlxSound;

	public var pauseScript:Script;

	public var game:PlayState = PlayState.instance; // shortcut

	private var __cancelDefault:Bool = false;

	public function new(x:Float, y:Float)
	{
		super();

		pauseScript = Script.create(Paths.script(script));
		pauseScript.setParent(this);
        pauseScript.load();

		var event = EventManager.get(PauseCreationEvent).recycle('breakfast', menuItems);
		pauseScript.call('create', [event]);

		menuItems = event.options;


		pauseMusic = new FlxSound().loadEmbedded(Paths.music(event.music), true, true);
		pauseMusic.volume = 0;
		pauseMusic.play(false, FlxG.random.int(0, Std.int(pauseMusic.length / 2)));
		FlxG.sound.list.add(pauseMusic);

		if (__cancelDefault = event.cancelled) return;

		var bg:FlxSprite = new FlxSprite().makeGraphic(1, 1, FlxColor.BLACK);
		bg.scale.set(FlxG.width, FlxG.height);
		bg.updateHitbox();
		bg.alpha = 0;
		bg.scrollFactor.set();
		add(bg);

		var levelInfo:FlxText = new FlxText(20, 15, 0, PlayState.SONG.song, 32);
		levelInfo.scrollFactor.set();
		levelInfo.setFormat(Paths.font("vcr.ttf"), 32);
		levelInfo.updateHitbox();
		add(levelInfo);

		var levelDifficulty:FlxText = new FlxText(20, 15 + 32, 0, PlayState.difficulty.toUpperCase(), 32);
		levelDifficulty.scrollFactor.set();
		levelDifficulty.setFormat(Paths.font('vcr.ttf'), 32);
		levelDifficulty.updateHitbox();
		add(levelDifficulty);

		levelDifficulty.alpha = 0;
		levelInfo.alpha = 0;

		levelInfo.x = FlxG.width - (levelInfo.width + 20);
		levelDifficulty.x = FlxG.width - (levelDifficulty.width + 20);

		FlxTween.tween(bg, {alpha: 0.6}, 0.4, {ease: FlxEase.quartInOut});
		FlxTween.tween(levelInfo, {alpha: 1, y: 20}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.3});
		FlxTween.tween(levelDifficulty, {alpha: 1, y: levelDifficulty.y + 5}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.5});

		grpMenuShit = new FlxTypedGroup<Alphabet>();
		add(grpMenuShit);

		for (i in 0...menuItems.length)
		{
			var songText:Alphabet = new Alphabet(0, (70 * i) + 30, menuItems[i], true, false);
			songText.isMenuItem = true;
			songText.targetY = i;
			grpMenuShit.add(songText);
		}

		changeSelection();

		camera = new FlxCamera();
		camera.bgColor = 0;
		FlxG.cameras.add(camera, false);

		pauseScript.call("postCreate");

		PlayState.instance.updateDiscordPresence();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (pauseMusic.volume < 0.5)
			pauseMusic.volume += 0.01 * elapsed;

		pauseScript.call("update", [elapsed]);

		if (__cancelDefault) return;

		var upP = controls.UP_P;
		var downP = controls.DOWN_P;
		var accepted = controls.ACCEPT;

		if (upP)
			changeSelection(-1);
		if (downP)
			changeSelection(1);
		if (accepted)
			selectOption();
	}

	public function selectOption() {
		var event = EventManager.get(NameEvent).recycle(menuItems[curSelected]);
		pauseScript.call("onSelectOption", [event]);

		if (event.cancelled) return;

		var daSelected:String = event.name;

		switch (daSelected)
		{
			case "Resume":
				close();
			case "Restart Song":
				FlxG.resetState();
			case "Change Controls":
				persistentDraw = false;
				openSubState(new KeybindsOptions());
			case "Options":
				FlxG.switchState(new OptionsMenu(true));
			case "Exit to menu":
				FlxG.switchState(PlayState.isStoryMode ? new StoryMenuState() : new FreeplayState());
				CoolUtil.playMenuSong();		
		}
	}
	override function destroy()
	{
		FlxG.cameras.remove(camera, true);
		pauseScript.call("onDestroy");
		if (pauseMusic != null) pauseMusic.destroy();
		pauseScript.destroy();

		super.destroy();
	}

	function changeSelection(change:Int = 0):Void
	{
		curSelected += change;

		if (curSelected < 0)
			curSelected = menuItems.length - 1;
		if (curSelected >= menuItems.length)
			curSelected = 0;

		var bullShit:Int = 0;

		for (item in grpMenuShit.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;
			// item.setGraphicSize(Std.int(item.width * 0.8));

			if (item.targetY == 0)
			{
				item.alpha = 1;
				// item.setGraphicSize(Std.int(item.width));
			}
		}
	}
}
