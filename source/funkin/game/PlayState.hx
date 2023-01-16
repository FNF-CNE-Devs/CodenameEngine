package funkin.game;

import funkin.game.SplashHandler;
import funkin.editors.CharacterEditor;
import funkin.scripting.DummyScript;
import funkin.menus.StoryMenuState.WeekData;
import funkin.ui.FunkinText;
import flixel.group.FlxSpriteGroup;
import funkin.options.Options;
import funkin.scripting.Script;
import flixel.util.FlxDestroyUtil;
import funkin.system.Section.SwagSection;
import funkin.system.Song.SwagSong;
import funkin.scripting.ScriptPack;
import funkin.shaders.WiggleEffect.WiggleEffectType;
import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.FlxSubState;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.effects.FlxTrail;
import flixel.addons.effects.FlxTrailArea;
import flixel.addons.effects.chainable.FlxEffectSprite;
import flixel.addons.effects.chainable.FlxWaveEffect;
import flixel.addons.transition.FlxTransitionableState;
import flixel.graphics.atlas.FlxAtlas;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;
import flixel.util.FlxCollision;
import flixel.util.FlxColor;
import flixel.util.FlxSort;
import flixel.util.FlxStringUtil;
import flixel.util.FlxTimer;
import haxe.Json;
import haxe.io.Path;
import lime.utils.Assets;
import openfl.display.BlendMode;
import openfl.display.StageQuality;
import openfl.filters.ShaderFilter;
import funkin.system.Conductor;
import funkin.system.Song;
import funkin.editors.ChartingState;
import funkin.debug.AnimationDebug;
import funkin.cutscenes.*;

import funkin.menus.*;
import funkin.scripting.events.*;

using StringTools;

@:access(flixel.text.FlxText.FlxTextFormatRange)
class PlayState extends MusicBeatState
{
	/**
	 * Current PlayState instance.
	 */
	public static var instance:PlayState = null;

	/**
	 * SONG METADATA
	 */
	public static var SONG:SwagSong;
	/**
	 * Whenever the song is being played in Story Mode.
	 */
	public static var isStoryMode:Bool = false;
	/**
	 * The week data of the current week
	 */
	public static var storyWeek:WeekData = null;
	/**
	 * The remaining songs in the Story Mode playlist.
	 */
	public static var storyPlaylist:Array<String> = [];
	/**
	 * The selected difficulty name
	 */
	public static var difficulty:String = "normal";
	/**
	 * Whenever the week is coming from the mods folder or not.
	 */
	public static var fromMods:Bool = false;

	/**
	 * Script Pack of all the scripts being ran.
	 */
	public var scripts:ScriptPack;

	/**
	 * Game Over Song. (assets/music/gameOver.ogg)
	 */
	public var gameOverSong:String = "gameOver";
	/**
	 * Game Over Song. (assets/sounds/gameOverSFX.ogg)
	 */
	public var lossSFX:String = "gameOverSFX";
	/**
	 * Game Over End SFX, used when retrying. (assets/sounds/gameOverEnd.ogg)
	 */
	public var retrySFX:String = "gameOverEnd";

	/**
	 * Current Stage.
	 */
	public var stage:Stage;
	/**
	 * Whenever the player can die.
	 */
	public var canDie:Bool = true;
	/**
	 * Current scroll speed for all strums.
	 * To set a scroll speed for a specific strum, use `strum.scrollSpeed`.
	 */
	public var scrollSpeed:Float = 0;
	/**
	 * Whenever the game is in downscroll or not. (Can be set)
	 */
	public var downscroll(get, set):Bool;

	@:dox(hide) private function set_downscroll(v:Bool) {return camHUD.downscroll = v;}
	@:dox(hide) private function get_downscroll():Bool  {return camHUD.downscroll;}

	/**
	 * Instrumental sound (Inst.ogg).
	 */
	public var inst:FlxSound;
	/**
	 * Vocals sound (Vocals.ogg).
	 */
	public var vocals:FlxSound;

	/**
	 * Dad character
	 */
	public var dad:Character;
	/**
	 * Girlfriend character
	 */
	public var gf:Character;
	/**
	 * Boyfriend character
	 */
	public var boyfriend:Character;

	/**
	 * Group of all of the notes. Using `forEach` on this group will only loop through the first notes.
	 */
	public var notes:NoteGroup;

	/**
	 * Strum line position
	 */
	public var strumLine:FlxObject;
	/**
	 * Number of ratings.
	 */
	public var ratingNum:Int = 0;

	/**
	 * Object defining the camera follow target.
	 */
	public var camFollow:FlxObject;

	/**
	 * Previous cam follow.
	 */
	private static var prevCamFollow:FlxObject;

	/**
	 * All of the strum line notes.
	 */
	public var strumLineNotes:FlxTypedGroup<Strum>;
	/**
	 * Player strums.
	 */
	public var playerStrums:FlxTypedGroup<Strum>;
	/**
	 * CPU strums.
	 */
	public var cpuStrums:FlxTypedGroup<Strum>;

	/**
	 * Note splashes container
	 */
	public var splashHandler:SplashHandler;

	/**
	 * Whenever the vocals should be muted when a note is missed.
	 */
	public var muteVocalsOnMiss:Bool = true;
	/**
	 * Whenever the player can press 7, 8 or 9 to access the debug menus.
	 */
	public var canAccessDebugMenus:Bool = true;

	/**
	 * Whenever cam zooming is enabled, enables on a note hit if not cancelled.
	 */
	public var camZooming:Bool = false;
	/**
	 * Interval of cam zooming (beats).
	 * For example: if set to 4, the camera will zoom every 4 beats.
	 */
	public var camZoomingInterval:Int = 4;
	/**
	 * How strong the cam zooms should be (defaults to 1)
	 */
	public var camZoomingStrength:Float = 1;
	/**
	 * Maximum amount of zoom for the camera.
	 */
	public var maxCamZoom:Float = 1.35;
	/**
	 * Current song name (lowercase)
	 */
	public var curSong:String = "";
	/**
	 * Current stage name
	 */
	public var curStage:String = "";

	/**
	 * Interval at which Girlfriend dances.
	 */
	public var gfSpeed:Int = 1;

	/**
	 * Current health. Goes from 0 to maxHealth (defaults to 2)
	 */
	public var health:Float = 1;

	/**
	 * Maximum health the player can have. Defaults to 2.
	 */
	@:isVar public var maxHealth(get, set):Float = 2;
	/**
	 * Current combo.
	 */
	public var combo:Int = 0;

	/**
	 * Whenever the misses should show "Combo Breaks" instead of "Misses"
	 */
	public var comboBreaks:Bool = false;
	/**
	 * Health bar background.
	 */
	public var healthBarBG:FlxSprite;
	/**
	 * Health bar.
	 */
	public var healthBar:FlxBar;

	/**
	 * Whenever the music has been generated.
	 */
	public var generatedMusic:Bool = false;
	/**
	 * Whenever the song is currently being started.
	 */
	public var startingSong:Bool = false;

	/**
	 * Player's icon
	 */
	public var iconP1:HealthIcon;
	/**
	 * Opponent's icon
	 */
	public var iconP2:HealthIcon;
	/**
	 * Camera for the HUD (notes, misses).
	 */
	public var camHUD:HudCamera;
	/**
	 * Camera for the game (stages, characters)
	 */
	public var camGame:FlxCamera;

	/**
	 * The player's current score.
	 */
	public var songScore:Int = 0;
	/**
	 * The player's amount of misses.
	 */
	public var misses:Int = 0;
	/**
	 * The player's accuracy (shortcut to `accuracyPressedNotes / totalAccuracyAmount`).
	 */
	public var accuracy(get, set):Float;
	/**
	 * The number of pressed notes.
	 */
	public var accuracyPressedNotes:Float = 0;
	/**
	 * The total accuracy amount.
	 */
	public var totalAccuracyAmount:Float = 0;

	/**
	 * FunkinText that shows your score.
	 */
	public var scoreTxt:FunkinText;
	/**
	 * FunkinText that shows your amount of misses.
	 */
	public var missesTxt:FunkinText;
	/**
	 * FunkinText that shows your accuracy.
	 */
	public var accuracyTxt:FunkinText;

	/**
	 * Score for the current week.
	 */
	public static var campaignScore:Int = 0;

	/**
	 * Camera zoom at which the game lerps to.
	 */
	public var defaultCamZoom:Float = 1.05;

	/**
	 * Zoom for the pixel assets.
	 */
	public static var daPixelZoom:Float = 6;

	/**
	 * Whenever the game is currently in a cutscene or not.
	 */
	public var inCutscene:Bool = false;

	/**
	 * Whenever the game should play the cutscenes. Defaults to whenever the game is currently in Story Mode or not.
	 */
	public var playCutscenes:Bool = isStoryMode;
	/**
	 * Cutscene script path.
	 */
	public var cutscene:String = null;
	/**
	 * End cutscene script path.
	 */
	public var endCutscene:String = null;

	/**
	 * Last rating (may be null)
	 */
	public var curRating:ComboRating;

	/**
	 * Timer for the start countdown
	 */
	public var startTimer:FlxTimer;

	/**
	 * Length of the intro countdown.
	 */
	public var introLength:Int = 5;
	/**
	 * Array of sprites for the intro.
	 */
	public var introSprites:Array<String> = [null, 'game/ready', "game/set", "game/go"];
	/**
	 * Array of sounds for the intro.
	 */
	public var introSounds:Array<String> = ['intro3', 'intro2', "intro1", "introGo"];

	/**
	 * Whenever the game is paused or not.
	 */
	public var paused:Bool = false;
	/**
	 * Whenever the countdown has started or not.
	 */
	public var startedCountdown:Bool = false;
	/**
	 * Whenever the game can be paused or not.
	 */
	public var canPause:Bool = true;

	/**
	 * Current section (can be `null` when using YoshiCrafter Engine charts).
	 */
	public var curSection(get, null):SwagSection;
	/**
	 * Format for the accuracy rating.
	 */
	public var accFormat:FlxTextFormat = new FlxTextFormat(0xFF888888, false, false, 0);
	/**
	 * Whenever the song is ending or not.
	 */
	public var endingSong:Bool = false;

	/**
	 * Group containing all of the combo sprites.
	 */
	public var comboGroup:FlxSpriteGroup;
	/**
	 * Array containing all of the note types names.
	 */
	public var noteTypesArray:Array<String> = [null];

	/**
	 * Hit window, in milliseconds. Defaults to 250ms unless changed in options.
	 * Base game hit window is 175ms.
	 */
	public var hitWindow:Float = Options.hitWindow; // is calculated in create(), is safeFrames in milliseconds

	@:dox(hide)
	var __vocalOffsetViolation:Float = 0;

	private function get_accuracy():Float {
		if (accuracyPressedNotes <= 0) return -1;
		return totalAccuracyAmount / accuracyPressedNotes;
	}
	private function set_accuracy(v:Float):Float {
		if (accuracyPressedNotes <= 0)
			accuracyPressedNotes = 1;
		return totalAccuracyAmount = v * accuracyPressedNotes;
	}
	/**
	 * All combo ratings.
	 */
	public var comboRatings:Array<ComboRating> = [
		new ComboRating(0, "F", 0xFFFF4444),
		new ComboRating(0.5, "E", 0xFFFF8844),
		new ComboRating(0.7, "D", 0xFFFFAA44),
		new ComboRating(0.8, "C", 0xFFFFFF44),
		new ComboRating(0.85, "B", 0xFFAAFF44),
		new ComboRating(0.9, "A", 0xFF88FF44),
		new ComboRating(0.95, "S", 0xFF44FFFF),
		new ComboRating(1, "S++", 0xFF44FFFF),
	];

	public var detailsText:String = "";
	public var detailsPausedText:String = "";

	public function updateRating() {
		var rating = null;
		var acc = get_accuracy();

		for(e in comboRatings) {
			if (e.percent <= acc && (rating == null || rating.percent < e.percent))
				rating = e;
		}

		var event = scripts.event("onRatingUpdate", EventManager.get(RatingUpdateEvent).recycle(rating, curRating));
		if (!event.cancelled)
			curRating = event.rating;
	}

	private inline function get_maxHealth()
		return this.maxHealth;
	private function set_maxHealth(v:Float) {
		if (healthBar != null && healthBar.max == this.maxHealth) {
			healthBar.setRange(healthBar.min, v);
		}
		return this.maxHealth = v;
	}

	override public function create()
	{
		instance = this;
		if (FlxG.sound.music != null) FlxG.sound.music.stop();

		PauseSubState.script = "";
		(scripts = new ScriptPack("PlayState")).setParent(this);

		camGame = camera;
		FlxG.cameras.add(camHUD = new HudCamera(), false);
		camHUD.bgColor.alpha = 0;

		downscroll = Options.downscroll;

		persistentUpdate = true;
		persistentDraw = true;

		if (SONG == null)
			SONG = Song.loadFromJson('tutorial', 'normal');

		scrollSpeed = SONG.speed;

		Conductor.setupSong(SONG);

		detailsText = isStoryMode ? ("Story Mode: " + storyWeek.name) : "Freeplay";

		// Checks if cutscene files exists
		var cutscenePath = Paths.script('songs/${SONG.song.toLowerCase()}/cutscene');
		var endCutscenePath = Paths.script('songs/${SONG.song.toLowerCase()}/cutscene-end');
		if (Assets.exists(cutscenePath)) cutscene = cutscenePath;
		if (Assets.exists(endCutscenePath)) endCutscene = endCutscenePath;

		// String for when the game is paused
		detailsPausedText = "Paused - " + detailsText;


		// Updating Discord Rich Presence.
		dad = new Character(100, 100, SONG.player2);


		if (dad != null && dad.isGF) {
			dad.setPosition(400, 130);
			gf = dad;
			dad.scrollFactor.set(0.95, 0.95);
		} else {
			var gfVersion = SONG.gf;
			if (gfVersion == null) gfVersion = "gf";
			if (gfVersion != "none") {
				gf = new Character(400, 130, gfVersion);
				gf.scrollFactor.set(0.95, 0.95);
			}
		}

		var dadMidpoint = dad.getGraphicMidpoint();
		var camPos:FlxPoint = new FlxPoint(dadMidpoint.x, dadMidpoint.y);
		dadMidpoint.put();


		comboGroup = new FlxSpriteGroup(FlxG.width * 0.55, (FlxG.height * 0.5) - 60);

		boyfriend = new Character(770, 100, SONG.player1, true);


		if (SONG.stage == null || SONG.stage.trim() == "") SONG.stage = "stage";
		add(stage = new Stage(SONG.stage));


		switch(SONG.song) {
			// case "":
				// ADD YOUR HARDCODED SCRIPTS HERE!
			default:
				for(content in [
					Paths.getFolderContent('songs/${SONG.song.toLowerCase()}/scripts', true, fromMods ? MODS : SOURCE),
					Paths.getFolderContent('data/charts/', true, fromMods ? MODS : SOURCE)]) {
					for(file in content) {
						var ext = Path.extension(file).toLowerCase();
						if (Script.scriptExtensions.contains(ext))
							scripts.add(Script.create(file));
					}
				}
		}

		/**
		 * PRECACHING
		 */

		for(content in Paths.getFolderContent('images/game/score/', true, true))
			FlxG.bitmap.add(content);

		/**
		 * END OF PRECACHING
		 */

		scripts.load();
		scripts.call("create");

		if (gf != null) {
			gf.danceOnBeat = false;
			add(gf);
		}

		add(comboGroup);

		if (dad != null) add(dad);
		if (boyfriend != null) add(boyfriend);




		strumLine = new FlxObject(0, 50, FlxG.width, 10);
		strumLine.scrollFactor.set();

		strumLineNotes = new FlxTypedGroup<Strum>();
		playerStrums = new FlxTypedGroup<Strum>();
		cpuStrums = new FlxTypedGroup<Strum>();
		add(strumLineNotes);

		splashHandler = new SplashHandler();
		add(splashHandler);

		generateSong(SONG);

		if (prevCamFollow != null)
		{
			camFollow = prevCamFollow;
			prevCamFollow = null;
		} else {
			camFollow = new FlxObject(0, 0, 2, 2);
			camFollow.setPosition(camPos.x, camPos.y);
		}
		add(camFollow);

		FlxG.camera.follow(camFollow, LOCKON, 0.04);
		FlxG.camera.zoom = defaultCamZoom;
		FlxG.camera.focusOn(camFollow.getPosition());

		FlxG.worldBounds.set(0, 0, FlxG.width, FlxG.height);

		healthBarBG = new FlxSprite(0, FlxG.height * 0.9).loadAnimatedGraphic(Paths.image('game/healthBar'));
		healthBarBG.screenCenter(X);
		healthBarBG.scrollFactor.set();
		add(healthBarBG);

		healthBar = new FlxBar(healthBarBG.x + 4, healthBarBG.y + 4, RIGHT_TO_LEFT, Std.int(healthBarBG.width - 8), Std.int(healthBarBG.height - 8), this,
			'health', 0, maxHealth);
		healthBar.scrollFactor.set();
		healthBar.createFilledBar(0xFFFF0000, 0xFF66FF33);
		add(healthBar);

		health = maxHealth / 2;


		iconP1 = new HealthIcon(boyfriend.getIcon(), true);
		iconP2 = new HealthIcon(dad.getIcon(), false);
		for(icon in [iconP1, iconP2]) {
			icon.y = healthBar.y - (icon.height / 2);
			add(icon);
		}

		scoreTxt = new FunkinText(healthBarBG.x + 50, healthBarBG.y + 30, Std.int(healthBarBG.width - 100), "Score:0", 16);
		missesTxt = new FunkinText(healthBarBG.x + 50, healthBarBG.y + 30, Std.int(healthBarBG.width - 100), "Misses:0", 16);
		accuracyTxt = new FunkinText(healthBarBG.x + 50, healthBarBG.y + 30, Std.int(healthBarBG.width - 100), "Acc:-% (N/A)", 16);
		accuracyTxt.addFormat(accFormat, 0, 1);

		for(text in [scoreTxt, missesTxt, accuracyTxt]) {
			text.scrollFactor.set();
			add(text);
		}
		scoreTxt.alignment = RIGHT;
		missesTxt.alignment = CENTER;
		accuracyTxt.alignment = LEFT;

		for(e in [strumLineNotes, notes, healthBar, healthBarBG, iconP1, iconP2, scoreTxt, missesTxt, accuracyTxt])
			e.cameras = [camHUD];

		startingSong = true;

		super.create();
	}
	public override function createPost() {
		startCutscene();
		super.createPost();

		updateDiscordPresence();

		scripts.call("postCreate");
	}

	public dynamic function updateDiscordPresence() {
		DiscordUtil.changeSongPresence(detailsText, (paused ? "Paused - " : "") + SONG.song + " (" + difficulty + ")", inst, getIconRPC());
	}

	public function startCutscene() {
		if (playCutscenes) {
			var videoCutscene = Paths.video('${PlayState.SONG.song.toLowerCase()}-cutscene');
			var videoCutsceneAlt = Paths.file('songs/${PlayState.SONG.song.toLowerCase()}/cutscene.mp4');
			persistentUpdate = false;
			if (cutscene != null) {
				openSubState(new ScriptedCutscene(cutscene, function() {
					startCountdown();
				}));
			} else if (Assets.exists(videoCutsceneAlt)) {
			FlxTransitionableState.skipNextTransIn = true;
				openSubState(new VideoCutscene(videoCutsceneAlt, function() {
					startCountdown();
				}));
				persistentDraw = false;
			}else if (Assets.exists(videoCutscene)) {
			FlxTransitionableState.skipNextTransIn = true;
				openSubState(new VideoCutscene(videoCutscene, function() {
					startCountdown();
				}));
				persistentDraw = false;
			} else {
				startCountdown();
			}
		} else
			startCountdown();
	}

	public function startEndCutscene() {
		if (playCutscenes) {
			var videoCutscene = Paths.video('${PlayState.SONG.song.toLowerCase()}-end-cutscene');
			var videoCutsceneAlt = Paths.file('songs/${PlayState.SONG.song.toLowerCase()}/end-cutscene.mp4');
			persistentUpdate = false;
			if (endCutscene != null) {
				openSubState(new ScriptedCutscene(endCutscene, function() {
					nextSong();
				}));
			} else if (Assets.exists(videoCutsceneAlt)) {
				openSubState(new VideoCutscene(videoCutsceneAlt, function() {
					nextSong();
				}));
				persistentDraw = false;
			} else if (Assets.exists(videoCutscene)) {
				openSubState(new VideoCutscene(videoCutscene, function() {
					nextSong();
				}));
				persistentDraw = false;
			} else {
				nextSong();
			}
		} else
			nextSong();
	}

	public function startCountdown():Void
	{

		inCutscene = false;

		generateStaticArrows(0);
		generateStaticArrows(1);
		scripts.call("onStartCountdown");

		startedCountdown = true;
		Conductor.songPosition = 0;
		Conductor.songPosition -= Conductor.crochet * introLength;

		var swagCounter:Int = 0;


		startTimer = new FlxTimer().start(Conductor.crochet / 1000, function(tmr:FlxTimer)
		{
			countdown(swagCounter++);
		}, introLength);
	}

	/**
	 * Creates a fake countdown.
	 */
	public function countdown(swagCounter:Int) {
		var event:CountdownEvent = scripts.event("onCountdown", EventManager.get(CountdownEvent).recycle(
			swagCounter,
			1,
			introSounds[swagCounter],
			introSprites[swagCounter],
			0.6, true, null, null, null));

		var sprite:FlxSprite = null;
		var sound:FlxSound = null;
		var tween:FlxTween = null;

		if (!event.cancelled) {
			if (event.spritePath != null) {
				var spr = event.spritePath;
				if (!Assets.exists(spr)) spr = Paths.image('$spr');

				sprite = new FlxSprite().loadAnimatedGraphic(spr);
				sprite.scrollFactor.set();
				sprite.scale.set(event.scale, event.scale);
				sprite.updateHitbox();
				sprite.screenCenter();
				add(sprite);
				tween = FlxTween.tween(sprite, {y: sprite.y + 100, alpha: 0}, Conductor.crochet / 1000, {
					ease: FlxEase.cubeInOut,
					onComplete: function(twn:FlxTween)
					{
						sprite.destroy();
						remove(sprite, true);
					}
				});
			}
			if (event.soundPath != null) {
				var sfx = event.soundPath;
				if (!Assets.exists(sfx)) sfx = Paths.sound(sfx);
				sound = FlxG.sound.play(sfx, event.volume);
			}
		}
		event.sprite = sprite;
		event.sound = sound;
		event.spriteTween = tween;
		event.cancelled = false;

		scripts.event("onPostCountdown", event);
	}

	function startSong():Void
	{
		scripts.call("onSongStart");
		startingSong = false;

		inst.onComplete = endSong;

		if (!paused) {
			FlxG.sound.music = inst;
			FlxG.sound.music.play();
		}
		vocals.play();

		vocals.pause();
		inst.pause();
		inst.time = vocals.time = 0;
		vocals.play();
		inst.play();

		updateDiscordPresence();
	}

	public override function destroy() {
		scripts.call("destroy");
		super.destroy();
		FlxDestroyUtil.destroy(scripts);
		@:privateAccess {
			FlxG.sound.destroySound(inst);
			FlxG.sound.destroySound(vocals);
		}
		instance = null;
	}

	public function generateNotes(songData:SwagSong) {
		if (songData == null) return;
		if (songData.noteTypes == null) songData.noteTypes = [];

		var noteData:Array<SwagSection> = songData.notes;
		var stepCrochet = Conductor.stepCrochet;

		for (section in noteData)
		{
			if (section == null || section.sectionNotes == null) continue;

			if (section.changeBPM && section.bpm > 0)
				stepCrochet = ((60 / section.bpm) * 250);

			for (songNotes in section.sectionNotes)
			{
				if (songNotes == null) continue;
				var daStrumTime:Float = songNotes[0];
				var daNoteData:Int = Std.int(songNotes[1] % 8);

				if (daNoteData < 0) continue;
				var daNoteType:Int = Std.int(songNotes[1] / 8);
				var gottaHitNote:Bool = daNoteData >= 4 ? !section.mustHitSection : section.mustHitSection;

				if (songNotes.length > 2) {
					if (songNotes[3] is Int)
						daNoteType = addNoteType(songData.noteTypes[Std.int(songNotes[3])-1], songNotes[3] == 0);
					else if (songNotes[3] is String)
						daNoteType = addNoteType(songNotes[3]);
				} else {
					daNoteType = addNoteType(songData.noteTypes[daNoteType-1], daNoteType == 0);
				}

				var swagNote:Note;
				if (notes.length > 0)
					swagNote = notes.members[Std.int(notes.members.length - 1)];
				else
					swagNote = null;

				swagNote.nextNote = (swagNote = new Note(daStrumTime, daNoteData % 4, daNoteType, gottaHitNote, swagNote, false, section.altAnim ? "-alt" : ""));
				swagNote.sustainLength = songNotes[2];
				swagNote.scrollFactor.set(0, 0);
				swagNote.stepLength = stepCrochet;
				notes.add(swagNote);

				// calculate sustain length and fix
				var susLength:Float = swagNote.sustainLength / stepCrochet;
				if (susLength > 0.75) susLength++;

				// create sustains
				for (susNote in 0...Math.floor(susLength))
				{
					swagNote = new Note(daStrumTime + (stepCrochet * susNote), daNoteData % 4, daNoteType, gottaHitNote, swagNote, true, section.altAnim ? "-alt" : "");
					swagNote.scrollFactor.set();
					swagNote.stepLength = stepCrochet;
					notes.add(swagNote);
				}

				splashHandler.getSplashGroup(swagNote.splash);
			}
		}
		notes.sortNotes();
	}
	private function generateSong(?songData:SwagSong):Void
	{
		if (songData == null) songData = SONG;

		if (songData.maxHealth != null && songData.maxHealth > 0)
			maxHealth = songData.maxHealth;

		Conductor.changeBPM(songData.bpm);

		curSong = songData.song.toLowerCase();

		inst = FlxG.sound.load(Paths.inst(PlayState.SONG.song));
		vocals = FlxG.sound.list.recycle(FlxSound);
		@:privateAccess {
			vocals.reset();
			vocals.exists = true;
		}
		if (SONG.needsVoices)
			vocals.loadEmbedded(Paths.voices(PlayState.SONG.song));
		FlxG.sound.list.add(vocals);

		inst.persist = vocals.persist = false;

		notes = new NoteGroup();
		add(notes);

		generateNotes(songData);

		generatedMusic = true;
	}

	public function addNoteType(name:String, addAsDefaultIfUnknown:Bool = false):Int {
		if (name == null) {
			if (addAsDefaultIfUnknown)
				return 0;
			else
				name = "Unknown";
		}

		for(k=>e in noteTypesArray)
			if (e == name) return k;

		noteTypesArray.push(name);

		// loads script
		var scriptPath = Paths.script('data/notes/${name}');
		if (Assets.exists(scriptPath) && !scripts.contains(scriptPath)) {
			var script = Script.create(scriptPath);
			if (!(script is DummyScript)) {
				scripts.add(script);
				script.load();
			}
		}
		return noteTypesArray.length-1;
	}
	function sortByShit(Obj1:Note, Obj2:Note):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);
	}

	private function generateStaticArrows(player:Int):Void
	{
		for (i in 0...4)
		{
			// FlxG.log.add(i);
			var babyArrow:Strum = new Strum((FlxG.width * 0.25) + (Note.swagWidth * (i - 2)) + ((FlxG.width / 2) * player), strumLine.y);
			babyArrow.ID = i;

			var event = scripts.event("onStrumCreation", EventManager.get(StrumCreationEvent).recycle(babyArrow, player, i));

			if (!event.cancelled) {
				switch (curStage)
				{
					// case "school":
					default:
						babyArrow.frames = Paths.getFrames(event.sprite);
						babyArrow.animation.addByPrefix('green', 'arrowUP');
						babyArrow.animation.addByPrefix('blue', 'arrowDOWN');
						babyArrow.animation.addByPrefix('purple', 'arrowLEFT');
						babyArrow.animation.addByPrefix('red', 'arrowRIGHT');

						babyArrow.antialiasing = true;
						babyArrow.setGraphicSize(Std.int(babyArrow.width * 0.7));

						switch (babyArrow.ID % 4)
						{
							case 0:
								babyArrow.animation.addByPrefix('static', 'arrowLEFT');
								babyArrow.animation.addByPrefix('pressed', 'left press', 24, false);
								babyArrow.animation.addByPrefix('confirm', 'left confirm', 24, false);
							case 1:
								babyArrow.animation.addByPrefix('static', 'arrowDOWN');
								babyArrow.animation.addByPrefix('pressed', 'down press', 24, false);
								babyArrow.animation.addByPrefix('confirm', 'down confirm', 24, false);
							case 2:
								babyArrow.animation.addByPrefix('static', 'arrowUP');
								babyArrow.animation.addByPrefix('pressed', 'up press', 24, false);
								babyArrow.animation.addByPrefix('confirm', 'up confirm', 24, false);
							case 3:
								babyArrow.animation.addByPrefix('static', 'arrowRIGHT');
								babyArrow.animation.addByPrefix('pressed', 'right press', 24, false);
								babyArrow.animation.addByPrefix('confirm', 'right confirm', 24, false);
						}
				}
			}

			babyArrow.updateHitbox();
			babyArrow.scrollFactor.set();

			if (event.__doAnimation)
			{
				babyArrow.y -= 10;
				babyArrow.alpha = 0;
				FlxTween.tween(babyArrow, {y: babyArrow.y + 10, alpha: 1}, 1, {ease: FlxEase.circOut, startDelay: 0.5 + (0.2 * i)});
			}


			if (event.player == 1)
				playerStrums.add(babyArrow);
			else {
				babyArrow.cpu = true;
				cpuStrums.add(babyArrow);
			}
			babyArrow.animation.play('static');
			strumLineNotes.add(babyArrow);
		}
	}

	override function openSubState(SubState:FlxSubState)
	{
		var event = scripts.event("onSubstateOpen", EventManager.get(StateEvent).recycle(SubState));

		if (!postCreated)
			FlxTransitionableState.skipNextTransIn = true;

		if (event.cancelled) return;

		if (paused)
		{
			if (FlxG.sound.music != null)
			{
				FlxG.sound.music.pause();
				vocals.pause();
			}

			if (!startTimer.finished)
				startTimer.active = false;
		}

		super.openSubState(SubState);
	}

	override function closeSubState()
	{
		var event = scripts.event("onSubstateClose", EventManager.get(StateEvent).recycle(subState));
		if (event.cancelled) return;

		if (paused)
		{
			if (FlxG.sound.music != null && !startingSong)
			{
				resyncVocals();
			}

			if (!startTimer.finished)
				startTimer.active = true;
			paused = false;

			updateDiscordPresence();
		}

		super.closeSubState();
	}
	public inline function getIconRPC():String
		return (dad != null ? (dad.icon != null ? dad.icon : dad.curCharacter) : SONG.player2);

	var __songPlaying:Bool = false;
	var __wasAutoPause:Bool = false;
	override public function onFocus():Void
	{
		scripts.call("onFocus");


		if (__wasAutoPause) {
			updateDiscordPresence();
			if (__songPlaying) {
				inst.play();
				vocals.play();
			}
		}

		super.onFocus();
	}

	override public function onFocusLost():Void
	{
		scripts.call("onFocusLost");
		updateDiscordPresence();
		if (__wasAutoPause = FlxG.autoPause) {
			__songPlaying = inst.playing;
			inst.pause();
			vocals.pause();
		}


		super.onFocusLost();
	}

	function resyncVocals():Void
	{
		vocals.pause();

		FlxG.sound.music.play();
		Conductor.songPosition = FlxG.sound.music.time;
		vocals.time = Conductor.songPosition;
		vocals.play();
		scripts.call("onVocalsResync");
	}

	public function get_curSection() {
		return PlayState.SONG.notes[Std.int(curStep / 16)];
	}


	public function pauseGame() {
		var e = scripts.event("onGamePause", new CancellableEvent());
		if (e.cancelled) return;

		persistentUpdate = false;
		persistentDraw = true;
		paused = true;

		// 1 / 1000 chance for Gitaroo Man easter egg
		if (FlxG.random.bool(0.1))
		{
			// gitaroo man easter egg
			FlxG.switchState(new GitarooPause());
		}
		else
			openSubState(new PauseSubState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));

		updateDiscordPresence();
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
		scripts.call("update", [elapsed]);

		scoreTxt.text = 'Score:$songScore';
		missesTxt.text = '${comboBreaks ? "Combo Breaks" : "Misses"}:$misses';
		var acc = accuracy;

		var rating:ComboRating = curRating == null ? new ComboRating(0, "[N/A]", 0xFF888888) : curRating;

		@:privateAccess accFormat.format.color = rating.color;
		accuracyTxt.text = 'Accuracy:${acc < 0 ? "-%" : '${FlxMath.roundDecimal(acc * 100, 2)}%'} - ${rating.rating}';

		@:privateAccess
		var format = accuracyTxt._formatRanges[0];
		format.range.start = accuracyTxt.text.length - rating.rating.length;
		format.range.end = accuracyTxt.text.length;
		// accuracyTxt.addFormat(accFormat, accuracyTxt.text.length - rating.rating.length, accuracyTxt.text.length);


		if (FlxG.keys.justPressed.ENTER && startedCountdown && canPause)
			pauseGame();

		if (canAccessDebugMenus) {
			if (FlxG.keys.justPressed.SEVEN)
			{
				FlxG.switchState(new ChartingState());
			}
			if (FlxG.keys.justPressed.F5) {
				Logs.trace('Reloading scripts...', WARNING, YELLOW);
				scripts.reload();
				Logs.trace('Song scripts successfully reloaded.', WARNING, GREEN);
			}
			if (FlxG.keys.justPressed.EIGHT)
				FlxG.switchState(new CharacterEditor(SONG.player2));
			if (FlxG.keys.justPressed.NINE)
				FlxG.switchState(new CharacterEditor(SONG.player1));
		}

		// FlxG.watch.addQuick('VOL', vocals.amplitudeLeft);
		// FlxG.watch.addQuick('VOLRight', vocals.amplitudeRight);

		iconP1.scale.set(lerp(iconP1.scale.x, 1, 0.33), lerp(iconP1.scale.y, 1, 0.33));
		iconP2.scale.set(lerp(iconP2.scale.x, 1, 0.33), lerp(iconP2.scale.y, 1, 0.33));

		iconP1.updateHitbox();
		iconP2.updateHitbox();

		var iconOffset:Int = 26;

		iconP1.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 1, 0)) - iconOffset);
		iconP2.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 1, 0))) - (iconP2.width - iconOffset);

		if (health > maxHealth)
			health = maxHealth;

		iconP1.health = healthBar.percent / 100;
		iconP2.health = 1 - (healthBar.percent / 100);

		if (startingSong)
		{
			if (startedCountdown)
			{
				Conductor.songPosition += FlxG.elapsed * 1000;
				if (Conductor.songPosition >= 0)
					startSong();
			}
		} else {
			__vocalOffsetViolation = Math.max(0, __vocalOffsetViolation + (FlxG.sound.music.time != vocals.time ? elapsed : -elapsed / 2));
			if (__vocalOffsetViolation > 25) {
				resyncVocals();
				__vocalOffsetViolation = 0;
			}
		}

		if (generatedMusic && curSection != null)
		{
			var dadPos = dad.getCameraPosition();
			var bfPos = boyfriend.getCameraPosition();
			var section = curSection;

			// from dad to bf
			var ratio:Float = 0;
			if (section.camTarget != null)
				ratio = section.camTarget;
			else
				ratio = section.mustHitSection ? 1 : 0;

			var event = scripts.event("onCameraMove", EventManager.get(CamMoveEvent).recycle(FlxPoint.get(FlxMath.lerp(dadPos.x, bfPos.x, ratio), FlxMath.lerp(dadPos.y, bfPos.y, ratio)), bfPos, dadPos, ratio, ratio >= 0.5));

			if (!event.cancelled) {
				camFollow.setPosition(
					event.position.x, event.position.y
				);
			}
			for(e in [event.position, event.bfCamPos, event.dadCamPos])
				e.put();
		}

		if (camZooming)
		{
			FlxG.camera.zoom = lerp(FlxG.camera.zoom, defaultCamZoom, 0.05);
			camHUD.zoom = lerp(camHUD.zoom, 1, 0.05);
		}

		FlxG.watch.addQuick("beatShit", curBeat);
		FlxG.watch.addQuick("stepShit", curStep);


		// RESET = Quick Game Over Screen
		if (controls.RESET)
			health = 0;

		// CHEAT = brandon's a pussy
		if (controls.CHEAT)
		{
			health += 1;
			trace("User is cheating!");
		}

		if (health <= 0 && canDie)
			gameOver();

		if (generatedMusic) {
			__updateNote_event = EventManager.get(NoteUpdateEvent);
			notes.forEachAlive(updateNote);
		}

		if (!inCutscene)
			keyShit();

		#if debug
		if (FlxG.keys.justPressed.ONE)
			endSong();
		#end

		scripts.call("postUpdate", [elapsed]);
	}

	var __updateNote_strum:Strum = null;
	var __updateNote_event:NoteUpdateEvent = null;
	function updateNote(daNote:Note)
	{
		for(e in (daNote.mustPress ? playerStrums : cpuStrums).members) {
			if (e.ID == daNote.noteData % 4) {
				__updateNote_strum = e;
				break; //ing bad
			}
		}

		var event = PlayState.instance.scripts.event("onNoteUpdate", __updateNote_event.recycle(daNote, FlxG.elapsed, __updateNote_strum));
		if (!event.cancelled) {
			if (event.__updateHitWindow) {
				if (daNote.mustPress)
				{
					daNote.canBeHit = (daNote.strumTime > Conductor.songPosition - (hitWindow * daNote.latePressWindow)
						&& daNote.strumTime < Conductor.songPosition + (hitWindow * daNote.earlyPressWindow));

					if (daNote.strumTime < Conductor.songPosition - hitWindow && !daNote.wasGoodHit)
						daNote.tooLate = true;
				}
				else
					daNote.canBeHit = false;
			}

			if (event.__autoCPUHit && !daNote.mustPress && !daNote.wasGoodHit && daNote.strumTime < Conductor.songPosition) goodNoteHit(daNote);

			if (daNote.wasGoodHit && daNote.isSustainNote && daNote.strumTime + (daNote.stepLength) < Conductor.songPosition) {
				deleteNote(daNote);
				return;
			}

			if (daNote.tooLate) {
				noteMiss(daNote);
				return;
			}


			if (event.strum == null) return;

			if (event.__reposNote) event.strum.updateNotePosition(daNote);
			event.strum.updateSustain(daNote);

			PlayState.instance.scripts.event("onNotePostUpdate", event);
		}

	}

	function gameOver(?character:String, ?gameOverSong:String, ?lossSFX:String, ?retrySFX:String) {
		character = character.getDefault((boyfriend != null) ? boyfriend.gameOverCharacter : "bf-dead");
		gameOverSong = gameOverSong.getDefault(this.gameOverSong);
		lossSFX = lossSFX.getDefault(this.lossSFX);
		retrySFX = retrySFX.getDefault(this.retrySFX);

		boyfriend.stunned = true;

		persistentUpdate = false;
		persistentDraw = false;
		paused = true;

		vocals.stop();
		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		openSubState(new GameOverSubstate(boyfriend.x, boyfriend.y, character, gameOverSong, lossSFX, retrySFX));
	}

	function endSong():Void
	{
		scripts.call("onSongEnd");
		canPause = false;
		inst.volume = 0;
		vocals.volume = 0;
		inst.pause();
		vocals.pause();

		if (SONG.validScore)
		{
			#if !switch
			Highscore.saveScore(SONG.song, {
				score: songScore,
				misses: misses,
				accuracy: accuracy
			}, difficulty);
			#end
		}

		startEndCutscene();
	}

	public function nextSong() {
		if (isStoryMode)
		{
			campaignScore += songScore;

			storyPlaylist.remove(storyPlaylist[0]);

			if (storyPlaylist.length <= 0)
			{

				FlxG.switchState(new StoryMenuState());

				if (SONG.validScore)
				{
					// TODO: more week info saving
					Highscore.saveWeekScore(storyWeek.name, {
						score: campaignScore
					}, difficulty);
				}
				FlxG.save.flush();
			}
			else
			{
				trace('LOADING NEXT SONG');
				trace(PlayState.storyPlaylist[0].toLowerCase(), difficulty);

				FlxTransitionableState.skipNextTransIn = true;
				FlxTransitionableState.skipNextTransOut = true;
				prevCamFollow = camFollow;

				PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0].toLowerCase(), difficulty);
				FlxG.sound.music.stop();

				FlxG.switchState(new PlayState());
			}
		}
		else
		{
			trace('WENT BACK TO FREEPLAY??');
			FlxG.switchState(new FreeplayState());
		}
	}

	@:gcOptimize
	var __funcsToExec:Array<Note->Void> = [];
	var __pressed:Array<Bool> = [];
	var __justPressed:Array<Bool> = [];
	var __justReleased:Array<Bool> = [];
	private function keyShit():Void
	{
		__funcsToExec.clear();
		__pressed.clear();
		__justPressed.clear();
		__justReleased.clear();

		__pressed.pushGroup(controls.NOTE_LEFT, controls.NOTE_DOWN, controls.NOTE_UP, controls.NOTE_RIGHT);
		__justPressed.pushGroup(controls.NOTE_LEFT_P, controls.NOTE_DOWN_P, controls.NOTE_UP_P, controls.NOTE_RIGHT_P);
		__justReleased.pushGroup(controls.NOTE_LEFT_R, controls.NOTE_DOWN_R, controls.NOTE_UP_R, controls.NOTE_RIGHT_R);

		var event = scripts.event("onKeyShit", EventManager.get(InputSystemEvent).recycle(__pressed, __justPressed, __justReleased));
		if (event.cancelled) return;

		__pressed = CoolUtil.getDefault(event.pressed, []);
		__justPressed = CoolUtil.getDefault(event.justPressed, []);
		__justReleased = CoolUtil.getDefault(event.justReleased, []);


		if (__pressed.contains(true)) {
			__funcsToExec.push(function(note:Note) {
				if (__pressed[note.strumID] && note.isSustainNote && note.canBeHit && note.mustPress && !note.wasGoodHit) {
					goodNoteHit(note);
				}
			});
		}

		var notePerStrum = [for(i in 0...4) null];
		if (__justPressed.contains(true)) {
			__funcsToExec.push(function(note:Note) {
				if (__justPressed[note.strumID] && !note.isSustainNote && note.mustPress && !note.wasGoodHit && note.canBeHit) {
					if (notePerStrum[note.strumID] == null) 										notePerStrum[note.strumID] = note;
					else if (Math.abs(notePerStrum[note.strumID].strumTime - note.strumTime) <= 5) deleteNote(note);
					else if (note.strumTime < notePerStrum[note.strumID].strumTime)					notePerStrum[note.strumID] = note;
				}
			});
		}

		if (__funcsToExec.length > 0) {
			notes.forEachAlive(function(note:Note) {
				for(e in __funcsToExec) e(note);
			});
		}

		for(e in notePerStrum) if (e != null) goodNoteHit(e);

		playerStrums.forEach(function(str:Strum) {
			str.updatePlayerInput(__pressed[str.ID], __justPressed[str.ID], __justReleased[str.ID]);
		});
		scripts.call("onPostKeyShit");
	}

	function noteMiss(note:Note):Void
	{
		var event:NoteHitEvent = scripts.event("onPlayerMiss", EventManager.get(NoteHitEvent).recycle(true, false, false, note, [boyfriend], true, note.noteType, "", "", "", note.strumID, -10, 0, -0.04, "shit"));

		if (event.cancelled) return;

		health += event.healthGain;
		if (gf != null && combo > 5 && gf.animOffsets.exists('sad'))
		{
			gf.playAnim('sad', true, MISS);
		}
		combo = 0;

		songScore -= 10;
		misses++;

		FlxG.sound.play(Paths.soundRandom('missnote', 1, 3), FlxG.random.float(0.1, 0.2));

		if (muteVocalsOnMiss) vocals.volume = 0;

		if (event.accuracy != null) {
			accuracyPressedNotes++;
			totalAccuracyAmount += event.accuracy;

			updateRating();
		}

		for(char in event.characters) {
			if (char == null) continue;

			char.stunned = true;
			char.playSingAnim(note.strumID, "miss", MISS);
		}
		// boyfriend.stunned = true;

		deleteNote(note);
	}

	public function getNoteType(id:Int):String {
		return noteTypesArray[id];
	}

	function goodNoteHit(note:Note):Void
	{
		if(note.wasGoodHit) return;

		note.wasGoodHit = true;

		/**
			* CALCULATES RATING
			*/
		var noteDiff = Math.abs(Conductor.songPosition - note.strumTime);
		var daRating:String = "sick";
		var score:Int = 300;
		var accuracy:Float = 1;

		if (noteDiff > hitWindow * 0.9)
		{
			daRating = 'shit';
			score = 50;
			accuracy = 0.25;
		}
		else if (noteDiff > hitWindow * 0.75)
		{
			daRating = 'bad';
			score = 100;
			accuracy = 0.45;
		}
		else if (noteDiff > hitWindow * 0.2)
		{
			daRating = 'good';
			score = 200;
			accuracy = 0.75;
		}

		var event:NoteHitEvent;
		if (note.mustPress)
			event = scripts.event("onPlayerHit", EventManager.get(NoteHitEvent).recycle(false, !note.isSustainNote, !note.isSustainNote, note, [boyfriend], true, note.noteType, "", "game/score/", "", note.strumID, score, note.isSustainNote ? null : accuracy, note.noteData > 0 ? 0.023 : 0.004, daRating, !note.isSustainNote && daRating == "sick"));
		else
			event = scripts.event("onDadHit", EventManager.get(NoteHitEvent).recycle(false, false, false, note, [dad], false, note.noteType, "", "game/score/", "", note.strumID, 0, null, 0, daRating, false));

		if (!event.cancelled) {
			if (event.accuracy != null) {
				accuracyPressedNotes++;
				totalAccuracyAmount += event.accuracy;

				updateRating();
			}
			if (event.countAsCombo) combo++;

			if (event.showRating || (event.showRating == null && event.player && !note.isSustainNote))
			{
				var rating:FlxSprite = comboGroup.recycle(FlxSprite);
				rating.resetSprite(-40, -60);
				comboGroup.remove(rating, true);

				songScore += score;

				rating.loadAnimatedGraphic(Paths.image('${event.ratingPrefix}$daRating${event.ratingSuffix}'));
				rating.acceleration.y = 550;
				rating.velocity.y -= FlxG.random.int(140, 175);
				rating.velocity.x -= FlxG.random.int(0, 10);

				var comboSpr:FlxSprite = comboGroup.recycle(FlxSprite).loadAnimatedGraphic(Paths.image('${event.ratingPrefix}combo${event.ratingSuffix}'));
				comboSpr.resetSprite(0, 0);
				comboGroup.remove(comboSpr, true);
				comboSpr.acceleration.y = 600;
				comboSpr.velocity.y -= 150;
				comboSpr.velocity.x += FlxG.random.int(1, 10);


				rating.scale.set(event.ratingScale, event.ratingScale);
				rating.antialiasing = event.ratingAntialiasing;
				comboSpr.scale.set(event.ratingScale, event.ratingScale);
				comboSpr.antialiasing = event.ratingAntialiasing;

				comboSpr.updateHitbox();
				rating.updateHitbox();

				var separatedScore:String = Std.string(combo).addZeros(3);


				if (combo == 0 || combo >= 10) {
					comboGroup.add(comboSpr);
					for (i in 0...separatedScore.length)
					{
						var numScore:FlxSprite = comboGroup.recycle(FlxSprite).loadAnimatedGraphic(Paths.image('${event.ratingPrefix}num${separatedScore.charAt(i)}${event.ratingSuffix}'));
						numScore.resetSprite((43 * i) - 90, 80);
						comboGroup.remove(numScore, true);
						numScore.antialiasing = event.numAntialiasing;
						numScore.scale.set(event.numScale, event.numScale);
						numScore.updateHitbox();

						numScore.acceleration.y = FlxG.random.int(200, 300);
						numScore.velocity.y -= FlxG.random.int(140, 160);
						numScore.velocity.x = FlxG.random.float(-5, 5);

						comboGroup.add(numScore);

						FlxTween.tween(numScore, {alpha: 0}, 0.2, {
							onComplete: function(tween:FlxTween)
							{
								numScore.exists = false;
							},
							startDelay: Conductor.crochet * 0.002
						});
					}
				}
				comboGroup.add(rating);

				FlxTween.tween(rating, {alpha: 0}, 0.2, {
					startDelay: Conductor.crochet * 0.001
				});

				FlxTween.tween(comboSpr, {alpha: 0}, 0.2, {
					onComplete: function(tween:FlxTween)
					{
						rating.exists = false;
						comboSpr.exists = false;
					},
					startDelay: Conductor.crochet * 0.001
				});

				ratingNum += 1;
			}

			health += event.healthGain;

			if (!event.animCancelled)
				for(char in event.characters)
					if (char != null)
						char.playSingAnim(event.direction, event.animSuffix);

			(event.player ? playerStrums : cpuStrums).forEach(function(str:Strum) {
				if (str.ID == Math.abs(note.strumID)) {
					if (!event.strumGlowCancelled) str.press(note.strumTime);
					if (event.showSplash) splashHandler.showSplash(note.splash, str);
				}
			});
		}

		if (event.unmuteVocals) vocals.volume = 1;
		if (event.enableCamZooming) camZooming = true;
		if (event.autoHitLastSustain) {
			if (note.nextSustain != null && note.nextSustain.nextSustain == null) {
				// its a tail!!
				note.wasGoodHit = true;
			}
		}

		if (event.deleteNote && !note.isSustainNote) deleteNote(note);
	}

	public function deleteNote(note:Note) {
		var event:SimpleNoteEvent = scripts.event("onNoteDelete", EventManager.get(SimpleNoteEvent).recycle(note));
		if (!event.cancelled) {
			scripts.call("onNoteDelete", [note]);
			note.kill();
			notes.remove(note, true);
			note.destroy();
		}
	}

	override function stepHit(curStep:Int)
	{
		super.stepHit(curStep);
		scripts.call("stepHit", [curStep]);
	}

	override function beatHit(curBeat:Int)
	{
		super.beatHit(curBeat);

		if (camZoomingInterval < 1) camZoomingInterval = 1;
		if (Options.camZoomOnBeat && camZooming && FlxG.camera.zoom < maxCamZoom && curBeat % camZoomingInterval == 0)
		{
			FlxG.camera.zoom += 0.015 * camZoomingStrength;
			camHUD.zoom += 0.03 * camZoomingStrength;
		}

		iconP1.scale.set(1.2, 1.2);
		iconP2.scale.set(1.2, 1.2);

		iconP1.updateHitbox();
		iconP2.updateHitbox();

		if (gf != null && curBeat % gfSpeed == 0)
			gf.tryDance();

		scripts.call("beatHit", [curBeat]);
	}
}

class ComboRating {
	public var percent:Float;
	public var rating:String;
	public var color:FlxColor;

	public function new(percent:Float, rating:String, color:FlxColor) {
		this.percent = percent;
		this.rating = rating;
		this.color = color;
	}
}