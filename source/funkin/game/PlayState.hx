package funkin.game;

import funkin.editors.charter.EventsData;
import funkin.backend.system.RotatingSpriteGroup;
import funkin.editors.charter.Charter;
import funkin.savedata.FunkinSave;
import flixel.graphics.FlxGraphic;
import funkin.backend.chart.Chart;
import funkin.backend.chart.ChartData;
import funkin.game.SplashHandler;
import funkin.backend.scripting.DummyScript;
import funkin.menus.StoryMenuState.WeekData;
import funkin.backend.FunkinText;
import flixel.group.FlxSpriteGroup;
import funkin.backend.scripting.Script;
import funkin.backend.scripting.ScriptPack;
import flixel.FlxSubState;
import flixel.addons.transition.FlxTransitionableState;
import flixel.math.FlxPoint;
import flixel.sound.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;
import flixel.util.FlxColor;
import flixel.util.FlxSort;
import flixel.util.FlxTimer;
import haxe.io.Path;
import funkin.backend.system.Conductor;
import funkin.game.cutscenes.*;

import funkin.menus.*;
import funkin.backend.scripting.events.*;

using StringTools;

@:access(flixel.text.FlxText.FlxTextFormatRange)
@:access(funkin.game.StrumLine)
class PlayState extends MusicBeatState
{
	/**
	 * Current PlayState instance.
	 */
	public static var instance:PlayState = null;

	/**
	 * SONG DATA (Chart, Metadata)
	 */
	public static var SONG:ChartData;
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
	 * Whenever Charting Mode has been enabled for this song.
	 */
	public static var chartingMode:Bool = false;
	/**
	 * Whenever the song has been started with opponent mode on.
	 */
	public static var opponentMode:Bool = false;
	/**
	//  * Whenever the song has been started with co-op mode on.
	 */
	public static var coopMode:Bool = false;

	/**
	 * Script Pack of all the scripts being ran.
	 */
	public var scripts:ScriptPack;

	/**
	 * Array of all the players in the stage.
	 */
	public var strumLines:FlxTypedGroup<StrumLine> = new FlxTypedGroup<StrumLine>();

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
	 * Whenever the score will save when you beat the song.
	 */
	public var validScore:Bool = true;
	/**
	 * Whenever the player can die.
	 */
	public var canDie:Bool = !opponentMode && !coopMode;
	/**
	 * Whenever Ghost Tapping is enabled.
	 */
	public var ghostTapping:Bool = Options.ghostTapping;
	/**
	 * Whenever the opponent can die.
	 */
	public var canDadDie:Bool = opponentMode && !coopMode;
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
	public var dad(get, set):Character;
	/**
	 * Girlfriend character
	 */
	public var gf(get, set):Character;
	/**
	 * Boyfriend character
	 */
	public var boyfriend(get, set):Character;

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
	private static var smoothTransitionData:PlayStateTransitionData;
	/**
	 * Player strums.
	 */
	public var playerStrums(get, null):StrumLine;
	/**
	 * CPU strums.
	 */
	public var cpuStrums(get, null):StrumLine;
	/**
	 * Shortcut to `playerStrums`.
	 */
	public var player(get, set):StrumLine;
	/**
	 * Shortcut to `cpuStrums`.
	 */
	public var cpu(get, set):StrumLine;

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
	public var gfSpeed(get, set):Int;

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
	public var comboBreaks:Bool = !Options.ghostTapping;
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
	 * Misses for the current week.
	 */
	public static var campaignMisses:Int = 0;

	/**
	 * Accuracy for the current week
	 */
	public static var campaignAccuracy(get, null):Float;

	public static var campaignAccuracyTotal:Float = 0;
	public static var campaignAccuracyCount:Float = 0;

	/**
	 * Camera zoom at which the game lerps to.
	 */
	public var defaultCamZoom:Float = 1.05;

	/**
	 * Camera zoom at which the hud lerps to.
	 */
	public var defaultHudZoom:Float = 1.0;

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
	 * Remaining events
	 */
	public var events:Array<ChartEvent> = [];
	/**
	 * Current camera target. -1 means no automatic camera targetting.
	 */
	public var curCameraTarget:Int = 0;
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
	public var comboGroup:RotatingSpriteGroup;
	/**
	 * Array containing all of the note types names.
	 */
	public var noteTypesArray:Array<String> = [null];

	/**
	 * Hit window, in milliseconds. Defaults to 250ms unless changed in options.
	 * Base game hit window is 175ms.
	 */
	public var hitWindow:Float = Options.hitWindow; // is calculated in create(), is safeFrames in milliseconds

	@:noCompletion @:dox(hide) private var _startCountdownCalled:Bool = false;

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

	@:unreflective
	private var __cachedGraphics:Array<FlxGraphic> = [];

	/**
	 * Updates the rating.
	 */
	public function updateRating() {
		var rating = null;
		var acc = get_accuracy();

		for(e in comboRatings)
			if (e.percent <= acc && (rating == null || rating.percent < e.percent))
				rating = e;

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

	@:dox(hide) override public function create()
	{
		Note.__customNoteTypeExists = [];
		// SCRIPTING & DATA INITIALISATION
		#if REGION
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
			SONG = Chart.parse('tutorial', 'normal');

		scrollSpeed = SONG.scrollSpeed;

		Conductor.setupSong(SONG);

		detailsText = isStoryMode ? ("Story Mode: " + storyWeek.name) : "Freeplay";

		// Checks if cutscene files exists
		var cutscenePath = Paths.script('songs/${SONG.meta.name.toLowerCase()}/cutscene');
		var endCutscenePath = Paths.script('songs/${SONG.meta.name.toLowerCase()}/cutscene-end');
		if (Assets.exists(cutscenePath)) cutscene = cutscenePath;
		if (Assets.exists(endCutscenePath)) endCutscene = endCutscenePath;

		// String for when the game is paused
		detailsPausedText = "Paused - " + detailsText;
		#end

		// CHARACTER INITIALISATION
		#if REGION
		comboGroup = new RotatingSpriteGroup(FlxG.width * 0.55, (FlxG.height * 0.5) - 60);
		comboGroup.maxSize = 25;
		#end

		// SCRIPTS & STAGE INITIALISATION
		#if REGION
		if (SONG.stage == null || SONG.stage.trim() == "") SONG.stage = "stage";
		add(stage = new Stage(SONG.stage));

		// var camPos:FlxPoint = new FlxPoint(dadMidpoint.x, dadMidpoint.y);
		// dadMidpoint.put();
		var camPos:FlxPoint = new FlxPoint(0, 0);

		if (!chartingMode || Options.charterEnablePlaytestScripts) {
			switch(SONG.meta.name) {
				// case "":
					// ADD YOUR HARDCODED SCRIPTS HERE!
				default:
					for(content in [Paths.getFolderContent('songs/${SONG.meta.name.toLowerCase()}/scripts', true, fromMods ? MODS : BOTH), Paths.getFolderContent('data/charts/', true, fromMods ? MODS : BOTH)])
						for(file in content) addScript(file);
					var songEvents:Array<String> = [];
					for (event in SONG.events)
						if (!songEvents.contains(event.name)) songEvents.push(event.name);

					for (file in Paths.getFolderContent('data/events/', true, fromMods ? MODS : BOTH)) {
						var fileName:String = Path.withoutExtension(Path.withoutDirectory(file));
						if (EventsData.eventsList.contains(fileName) && songEvents.contains(fileName)) addScript(file);
					}
			}
		}

		add(comboGroup);
		#end

		// PRECACHING
		#if REGION
		for(content in Paths.getFolderContent('images/game/score/', true, true))
			graphicCache.cache(Paths.getPath(content));

		for(i in 1...4) {
			FlxG.sound.load(Paths.sound('missnote' + Std.string(i)));
		}
		#end

		// STRUMS & NOTES INITIALISATION
		#if REGION
		strumLine = new FlxObject(0, 50, FlxG.width, 10);
		strumLine.scrollFactor.set();

		generateSong(SONG);

		for(noteType in SONG.noteTypes) {
			var scriptPath = Paths.script('data/notes/${noteType}');
			if (Assets.exists(scriptPath) && !scripts.contains(scriptPath)) {
				var script = Script.create(scriptPath);
				if (!(script is DummyScript)) {
					scripts.add(script);
					script.load();
				}
			}
		}

		for(i=>strumLine in SONG.strumLines) {
			if (strumLine == null) continue;

			var chars = [];
			var charPosName:String = strumLine.position == null ? (switch(strumLine.type) {
				case 0: "dad";
				case 1: "boyfriend";
				case 2: "girlfriend";
			}) : strumLine.position;
			if (strumLine.characters != null) for(k=>charName in strumLine.characters) {
				var char = new Character(0, 0, charName, stage.isCharFlipped(charPosName, strumLine.type == 1));
				stage.applyCharStuff(char, charPosName, k);
				chars.push(char);
			}

			var strOffset:Float = strumLine.strumLinePos == null ? (strumLine.type == 1 ? 0.75 : 0.25) : strumLine.strumLinePos;

			var startingPos:FlxPoint = strumLine.strumPos == null ?
				FlxPoint.get((FlxG.width * strOffset) - ((Note.swagWidth * (strumLine.strumScale == null ? 1 : strumLine.strumScale)) * 2), this.strumLine.y) :
				FlxPoint.get(strumLine.strumPos[0], strumLine.strumPos[1]);

			var strLine = new StrumLine(chars,
				startingPos,
				strumLine.strumScale == null ? 1 : strumLine.strumScale,
				strumLine.type == 2 || (!coopMode && !((strumLine.type == 1 && !opponentMode) || (strumLine.type == 0 && opponentMode))), 
				strumLine.type != 1, coopMode ? (strumLine.type == 1 ? controlsP1 : controlsP2) : controls
			);
			strLine.cameras = [camHUD];
			strLine.data = strumLine;
			strLine.visible = (strumLine.visible != false);
			strLine.ID = i;
			strumLines.add(strLine);
		}

		add(strumLines);

		splashHandler = new SplashHandler();
		add(splashHandler);

		scripts.load();
		scripts.call("create");
		#end

		// CAMERA & HUD INITIALISATION
		#if REGION
		var event = EventManager.get(AmountEvent).recycle(4);
		if (!scripts.event("onPreGenerateStrums", event).cancelled) {
			generateStrums(event.amount);
			scripts.event("onPostGenerateStrums", event);
		}

		for(str in strumLines)
			str.generate(str.data, (chartingMode && Charter.startHere) ? Charter.startTime : null);

		camFollow = new FlxObject(0, 0, 2, 2);
		camFollow.setPosition(camPos.x, camPos.y);
		add(camFollow);

		FlxG.camera.follow(camFollow, LOCKON, 0.04);
		FlxG.camera.zoom = defaultCamZoom;
		// camHUD.zoom = defaultHudZoom;
		if (smoothTransitionData != null && smoothTransitionData.stage == curStage) {
			FlxG.camera.scroll.set(smoothTransitionData.camX, smoothTransitionData.camY);
			FlxG.camera.zoom = smoothTransitionData.camZoom;
			MusicBeatState.skipTransIn = true;
			camFollow.setPosition(smoothTransitionData.camFollowX, smoothTransitionData.camFollowY);
		} else {
			FlxG.camera.focusOn(camFollow.getPosition());
		}
		smoothTransitionData = null;

		FlxG.worldBounds.set(0, 0, FlxG.width, FlxG.height);

		healthBarBG = new FlxSprite(0, FlxG.height * 0.9).loadAnimatedGraphic(Paths.image('game/healthBar'));
		healthBarBG.screenCenter(X);
		healthBarBG.scrollFactor.set();
		add(healthBarBG);



		healthBar = new FlxBar(healthBarBG.x + 4, healthBarBG.y + 4, RIGHT_TO_LEFT, Std.int(healthBarBG.width - 8), Std.int(healthBarBG.height - 8), this,
			'health', 0, maxHealth);
		healthBar.scrollFactor.set();
		if (opponentMode)
			healthBar.createFilledBar(0xFF66FF33, 0xFFFF0000); // switch the colors
		else
			healthBar.createFilledBar(0xFFFF0000, 0xFF66FF33);
		add(healthBar);

		health = maxHealth / 2;


		iconP1 = new HealthIcon(boyfriend != null ? boyfriend.getIcon() : "face", true);
		iconP2 = new HealthIcon(dad != null ? dad.getIcon() : "face", false);
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

		for(e in [healthBar, healthBarBG, iconP1, iconP2, scoreTxt, missesTxt, accuracyTxt])
			e.cameras = [camHUD];
		#end

		startingSong = true;

		super.create();

		for(s in introSprites)
			if (s != null)
				graphicCache.cache(Paths.image(s));

		for(s in introSounds)
			if (s != null)
				FlxG.sound.load(Paths.sound(s));
	}

	@:dox(hide) public override function createPost() {
		startCutscene("", cutscene);
		super.createPost();

		updateDiscordPresence();

		__updateNote_event = EventManager.get(NoteUpdateEvent);

		scripts.call("postCreate");
	}

	/**
	 * Function used to update Discord Presence.
	 * This function is dynamic, which means you can do `updateDiscordPresence = function() {}` in scripts.
	 */
	public dynamic function updateDiscordPresence()
		DiscordUtil.changeSongPresence(detailsText, (paused ? "Paused - " : "") + SONG.meta.displayName + " (" + difficulty + ")", inst, getIconRPC());

	/**
	 * Starts a cutscene.
	 * @param prefix Custom prefix. Using `midsong-` will require you to for example rename your video cutscene to `songs/song/midsong-cutscene.mp4` instead of `songs/song/cutscene.mp4`
	 * @param cutsceneScriptPath Optional: Custom script path.
	 * @param callback Callback called after the cutscene ended. If equals to `null`, `startCountdown` will be called.
	 */
	public function startCutscene(prefix:String = "", ?cutsceneScriptPath:String, ?callback:Void->Void) {
		if (callback == null)
			callback = startCountdown;
		if (cutsceneScriptPath == null)
			cutsceneScriptPath = Paths.script('songs/${SONG.meta.name.toLowerCase()}/${prefix}cutscene');

		if (playCutscenes) {
			inCutscene = true;
			var videoCutscene = Paths.video('${PlayState.SONG.meta.name.toLowerCase()}-${prefix}cutscene');
			var videoCutsceneAlt = Paths.file('songs/${PlayState.SONG.meta.name.toLowerCase()}/${prefix}cutscene.mp4');
			var dialogue = Paths.file('songs/${PlayState.SONG.meta.name.toLowerCase()}/${prefix}dialogue.xml');
			persistentUpdate = true;
			if (cutsceneScriptPath != null && Assets.exists(cutsceneScriptPath)) {
				openSubState(new ScriptedCutscene(cutsceneScriptPath, function() {
					callback();
				}));
			} else if (Assets.exists(dialogue)) {
				MusicBeatState.skipTransIn = true;
				openSubState(new DialogueCutscene(dialogue, function() {
					callback();
				}));
			} else if (Assets.exists(videoCutsceneAlt)) {
				MusicBeatState.skipTransIn = true;
				persistentUpdate = false;
				openSubState(new VideoCutscene(videoCutsceneAlt, function() {
					callback();
				}));
				persistentDraw = false;
			} else if (Assets.exists(videoCutscene)) {
				MusicBeatState.skipTransIn = true;
				persistentUpdate = false;
				openSubState(new VideoCutscene(videoCutscene, function() {
					callback();
				}));
				persistentDraw = false;
			} else
				callback();
		} else
			callback();
	}

	@:dox(hide) public function startCountdown():Void
	{
		if (!_startCountdownCalled) {
			_startCountdownCalled = true;
			inCutscene = false;

			if (scripts.event("onStartCountdown", new CancellableEvent()).cancelled) return;
		}

		startedCountdown = true;
		Conductor.songPosition = 0;
		Conductor.songPosition -= Conductor.crochet * introLength;

		var swagCounter:Int = 0;

		startTimer = new FlxTimer().start(Conductor.crochet / 1000, function(tmr:FlxTimer)
		{
			countdown(swagCounter++);
		}, introLength);
		scripts.call("onPostStartCountdown");
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

	@:dox(hide) function startSong():Void
	{
		scripts.call("onSongStart");
		startingSong = false;

		inst.onComplete = endSong;

		if (!paused) {
			FlxG.sound.setMusic(inst);
			FlxG.sound.music.play();
		}
		vocals.play();

		vocals.pause();
		inst.pause();
		inst.time = vocals.time = (chartingMode && Charter.startHere) ? Charter.startTime : 0;
		vocals.play();
		inst.play();

		updateDiscordPresence();

		scripts.call("onStartSong");
	}

	public override function destroy() {
		scripts.call("destroy");
		for(g in __cachedGraphics)
			g.useCount--;
		super.destroy();
		scripts = FlxDestroyUtil.destroy(scripts);
		@:privateAccess {
			FlxG.sound.destroySound(inst);
			FlxG.sound.destroySound(vocals);
		}
		instance = null;

		Note.__customNoteTypeExists = [];
	}

	@:dox(hide) private function generateSong(?songData:ChartData):Void
	{
		if (songData == null) songData = SONG;

		events = songData.events != null ? [for(e in songData.events) e] : [];
		// get first camera focus
		for(e in events) {
			if (e.time > 10) break;
			if (e.name == "Camera Movement") {
				executeEvent(e);
				break;
			}
		}
		events.sort(function(p1, p2) {
			return FlxSort.byValues(FlxSort.DESCENDING, p1.time, p2.time);
		});

		camZoomingInterval = cast songData.meta.beatsPerMesure.getDefault(4);

		Conductor.changeBPM(songData.meta.bpm);

		curSong = songData.meta.name.toLowerCase();

		inst = FlxG.sound.load(Paths.inst(SONG.meta.name, difficulty));
		if (SONG.meta.needsVoices != false) // null or true
			vocals = FlxG.sound.load(Paths.voices(SONG.meta.name, difficulty));
		else
			vocals = new FlxSound();
		inst.group = FlxG.sound.defaultMusicGroup;
		vocals.group = FlxG.sound.defaultMusicGroup;

		inst.persist = vocals.persist = false;

		generatedMusic = true;
	}

	@:dox(hide) function sortByShit(Obj1:Note, Obj2:Note):Int {
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);
	}

	@:dox(hide)
	private inline function generateStrums(amount:Int = 4):Void
		for(p in strumLines)
			p.generateStrums(amount);

	@:dox(hide)
	override function openSubState(SubState:FlxSubState)
	{
		var event = scripts.event("onSubstateOpen", EventManager.get(StateEvent).recycle(SubState));

		if (!postCreated)
			MusicBeatState.skipTransIn = true;

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

	@:dox(hide)
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

	/**
	 * Returns the Discord RPC icon.
	 */
	public inline function getIconRPC():String
		return SONG.meta.icon;

	var __songPlaying:Bool = false;
	var __wasAutoPause:Bool = false;
	@:dox(hide)
	override public function onFocus():Void
	{
		if (!paused && FlxG.autoPause) {
			inst.resume();
			vocals.resume();
		}
		scripts.call("onFocus");
		updateDiscordPresence();
		super.onFocus();
	}

	@:dox(hide)
	override public function onFocusLost():Void
	{
		if (!paused && FlxG.autoPause) {
			inst.pause();
			vocals.pause();
		}
		scripts.call("onFocusLost");
		updateDiscordPresence();
		super.onFocusLost();
	}

	@:dox(hide)
	function resyncVocals():Void
	{
		vocals.pause();

		FlxG.sound.music.play();
		Conductor.songPosition = FlxG.sound.music.time;
		vocals.time = Conductor.songPosition;
		vocals.play();
		scripts.call("onVocalsResync");
	}

	/**
	 * Pauses the game.
	 */
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
		else {
			openSubState(new PauseSubState());
		}

		updateDiscordPresence();
	}

	@:dox(hide)
	override public function update(elapsed:Float)
	{
		scripts.call("update", [elapsed]);

		if (inCutscene) {
			super.update(elapsed);
			scripts.call("postUpdate", [elapsed]);
			return;
		}

		scoreTxt.text = 'Score:$songScore';
		missesTxt.text = '${comboBreaks ? "Combo Breaks" : "Misses"}:$misses';

		if (curRating == null)
			curRating = new ComboRating(0, "[N/A]", 0xFF888888);

		@:privateAccess {
			accFormat.format.color = curRating.color;
			accuracyTxt.text = 'Accuracy:${accuracy < 0 ? "-%" : '${FlxMath.roundDecimal(accuracy * 100, 2)}%'} - ${curRating.rating}';

			accuracyTxt._formatRanges[0].range.start = accuracyTxt.text.length - curRating.rating.length;
			accuracyTxt._formatRanges[0].range.end = accuracyTxt.text.length;
		}

		if (controls.PAUSE && startedCountdown && canPause)
			pauseGame();

		if (canAccessDebugMenus) {
			if (chartingMode && FlxG.keys.justPressed.SEVEN) {
				FlxG.switchState(new funkin.editors.charter.Charter(SONG.meta.name, difficulty, false));
			}
			if (FlxG.keys.justPressed.F5) {
				Logs.trace('Reloading scripts...', WARNING, YELLOW);
				scripts.reload();
				Logs.trace('Song scripts successfully reloaded.', WARNING, GREEN);
			}
		}

		iconP1.scale.set(lerp(iconP1.scale.x, 1, 0.33), lerp(iconP1.scale.y, 1, 0.33));
		iconP2.scale.set(lerp(iconP2.scale.x, 1, 0.33), lerp(iconP2.scale.y, 1, 0.33));

		iconP1.updateHitbox();
		iconP2.updateHitbox();

		var iconOffset:Int = 26;

		iconP1.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 1, 0)) - iconOffset);
		iconP2.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 1, 0))) - (iconP2.width - iconOffset);

		health = FlxMath.bound(health, 0, maxHealth);

		iconP1.health = healthBar.percent / 100;
		iconP2.health = 1 - (healthBar.percent / 100);

		if (startingSong)
		{
			if (startedCountdown)
			{
				Conductor.songPosition += elapsed * 1000;
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

		while(events.length > 0 && events.last().time <= Conductor.songPosition)
			executeEvent(events.pop());

		if (generatedMusic && strumLines.members[curCameraTarget] != null)
		{
			var pos = FlxPoint.get();
			var r = 0;
			for(c in strumLines.members[curCameraTarget].characters) {
				if (c == null) continue;
				var cpos = c.getCameraPosition();
				pos.x += cpos.x;
				pos.y += cpos.y;
				r++;
				cpos.put();
			}
			if (r > 0) {
				pos.x /= r;
				pos.y /= r;

				var event = scripts.event("onCameraMove", EventManager.get(CamMoveEvent).recycle(pos, strumLines.members[curCameraTarget], r));
				if (!event.cancelled)
					camFollow.setPosition(pos.x, pos.y);
			}
			pos.put();
		}

		if (camZooming)
		{
			FlxG.camera.zoom = lerp(FlxG.camera.zoom, defaultCamZoom, 0.05);
			camHUD.zoom = lerp(camHUD.zoom, defaultHudZoom, 0.05);
		}

		// RESET = Quick Game Over Screen
		if (startedCountdown && controls.RESET)
			gameOver();

		if (health <= 0 && canDie)
			gameOver(boyfriend);
		else if (health >= maxHealth && canDadDie)
			gameOver(dad);

		if (!inCutscene)
			keyShit();

		#if debug
		if (generatedMusic && FlxG.keys.justPressed.ONE)
			endSong();
		#end

		super.update(elapsed);

		scripts.call("postUpdate", [elapsed]);
	}

	override function draw() {
		var e = scripts.event("draw", EventManager.get(DrawEvent).recycle());
		if (!e.cancelled)
			super.draw();
		scripts.event("postDraw", e);
	}

	public function executeEvent(event:ChartEvent) {
		if (event == null) return;
		if (event.params == null) return;

		if (scripts.event("onEvent", EventManager.get(EventGameEvent).recycle(event)).cancelled) return;

		switch(event.name) {
			case "HScript Call":
				if (event.params[0] is String && event.params[1] is String) {
					scripts.call(event.params[0], event.params[1].split(','));
				}
			case "Camera Movement":
				if (event.params[0] is Int)
					curCameraTarget = event.params[0];
			case "BPM Change": // automatically handled by conductor
			case "Alt Animation Toggle":
				if (event.params[0] is Int && event.params[1] is Bool) {
					var strLine = strumLines.members[event.params[0]];
					if (strLine != null)
						strLine.altAnim = cast event.params[1];
				}
			case "Unknown":
		}
	}

	@:dox(hide)
	public var __updateNote_event:NoteUpdateEvent = null;

	/**
	 * Forces a game over.
	 * @param character Character which died. Default to `boyfriend`.
	 * @param deathCharID Character ID (name) for game over. Default to whatever is specified in the character's XML.
	 * @param gameOverSong Song for the game over screen. Default to `this.gameOverSong` (`gameOver`)
	 * @param lossSFX SFX at the beginning of the game over (Mic drop). Default to `this.lossSFX` (`gameOverSFX`)
	 * @param retrySFX SFX played whenever the player retries. Defaults to `retrySFX` (`gameOverEnd`)
	 */
	public function gameOver(?character:Character, ?deathCharID:String, ?gameOverSong:String, ?lossSFX:String, ?retrySFX:String) {
		character = character.getDefault(opponentMode ? dad : boyfriend);
		deathCharID = deathCharID.getDefault(character != null ? character.gameOverCharacter : "bf-dead");
		gameOverSong = gameOverSong.getDefault(this.gameOverSong);
		lossSFX = lossSFX.getDefault(this.lossSFX);
		retrySFX = retrySFX.getDefault(this.retrySFX);

		if (character != null)
			character.stunned = true;

		persistentUpdate = false;
		persistentDraw = false;
		paused = true;

		vocals.stop();
		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		openSubState(new GameOverSubstate(character == null ? 0 : character.x, character == null ? 0 : character.y, deathCharID, character != null ? character.isPlayer : true, gameOverSong, lossSFX, retrySFX));
	}

	/**
	 * Ends the song.
	 */
	public function endSong():Void
	{
		scripts.call("onSongEnd");
		canPause = false;
		inst.volume = 0;
		vocals.volume = 0;
		inst.pause();
		vocals.pause();

		if (validScore)
		{
			#if !switch
			FunkinSave.setSongHighscore(SONG.meta.name, difficulty, {
				score: songScore,
				misses: misses,
				accuracy: accuracy,
				hits: [],
				date: Date.now().toString()
			}, getSongChanges());
			#end
		}

		startCutscene("end-", endCutscene, nextSong);
	}

	private static inline function getSongChanges():Array<HighscoreChange> {
		var a = [];
		if (opponentMode)
			a.push(COpponentMode);
		if (coopMode)
			a.push(CCoopMode);
		return a;
	}

	/**
	 * Immediately switches to the next song, or goes back to the Story/Freeplay menu.
	 */
	public function nextSong() {
		if (isStoryMode)
		{
			campaignScore += songScore;
			campaignMisses += misses;
			campaignAccuracyTotal += accuracy;
			campaignAccuracyCount++;
			storyPlaylist.shift();

			if (storyPlaylist.length <= 0)
			{
				FlxG.switchState(new StoryMenuState());

				if (validScore)
				{
					// TODO: more week info saving
					FunkinSave.setWeekHighscore(storyWeek.id, difficulty, {
						score: campaignScore,
						misses: campaignMisses,
						accuracy: campaignAccuracy,
						hits: [],
						date: Date.now().toString()
					});
				}
				FlxG.save.flush();
			}
			else
			{
				trace('LOADING NEXT SONG');
				trace(PlayState.storyPlaylist[0].toLowerCase(), difficulty);

				registerSmoothTransition();

				FlxG.sound.music.stop();

				PlayState.__loadSong(PlayState.storyPlaylist[0].toLowerCase(), difficulty);

				FlxG.switchState(new PlayState());
			}
		}
		else
		{
			trace('WENT BACK TO FREEPLAY??');
			FlxG.switchState(new FreeplayState());
		}
	}

	public function registerSmoothTransition() {
		smoothTransitionData = {
			stage: curStage,
			camX: FlxG.camera.scroll.x,
			camY: FlxG.camera.scroll.y,
			camFollowX: camFollow.x,
			camFollowY: camFollow.y,
			camZoom: FlxG.camera.zoom
		};
		MusicBeatState.skipTransIn = true;
		MusicBeatState.skipTransOut = true;
	}

	private inline function keyShit():Void
	{
		for(id=>p in strumLines.members)
			p.updateInput(id);
	}

	/**
	 * Misses a note
	 * @param strumLine The strumline the miss happened on.
	 * @param note Note to miss.
	 * @param direction Specify a custom direction in case note is null.
	 * @param player Specify a custom player in case note is null.
	 */
	public function noteMiss(strumLine:StrumLine, note:Note, ?direction:Int, ?player:Int):Void
	{
		var playerID:Null<Int> = note == null ? player : strumLines.members.indexOf(strumLine);
		var directionID:Null<Int> = note == null ? direction : note.strumID;
		if (playerID == null || directionID == null || playerID == -1) return;

		var event:NoteMissEvent = scripts.event("onPlayerMiss", EventManager.get(NoteMissEvent).recycle(note, -10, 1, muteVocalsOnMiss, note != null ? -0.0475 : -0.04, Paths.soundRandom('missnote', 1, 3), FlxG.random.float(0.1, 0.2), note == null, combo > 5, "sad", true, true, "miss", strumLines.members[playerID].characters, playerID, note != null ? note.noteType : null, directionID, 0));
		strumLine.onMiss.dispatch(event);
		if (event.cancelled) return;

		if (strumLine != null) strumLine.addHealth(event.healthGain);
		if (gf != null && event.gfSad && gf.hasAnimation(event.gfSadAnim))
			gf.playAnim(event.gfSadAnim, event.forceGfAnim, MISS);

		if (event.resetCombo) combo = 0;

		songScore += event.score;
		misses += event.misses;

		if (event.playMissSound) FlxG.sound.play(event.missSound, event.missVolume);

		if (event.muteVocals) vocals.volume = 0;

		if (event.accuracy != null) {
			accuracyPressedNotes++;
			totalAccuracyAmount += event.accuracy;

			updateRating();
		}

		if (!event.animCancelled) {
			for(char in event.characters) {
				if (char == null) continue;

				if(event.stunned) char.stunned = true;
				char.playSingAnim(directionID, event.animSuffix, MISS, event.forceAnim);
			}
		}

		if (event.deleteNote && strumLine != null && note != null)
			strumLine.deleteNote(note);
	}

	@:dox(hide)
	public function getNoteType(id:Int):String {
		return SONG.noteTypes[id-1];
	}

	/**
	 * Hits a note
	 * @param note Note to hit.
	 */
	public function goodNoteHit(strumLine:StrumLine, note:Note):Void
	{
		if(note == null || note.wasGoodHit) return;

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
		if (strumLine != null && !strumLine.cpu)
			event = scripts.event("onPlayerHit", EventManager.get(NoteHitEvent).recycle(false, !note.isSustainNote, !note.isSustainNote, note, strumLine.characters, true, note.noteType, note.animSuffix.getDefault(strumLine.altAnim ? "-alt" : ""), "game/score/", "", note.strumID, score, note.isSustainNote ? null : accuracy, 0.023, daRating, Options.splashesEnabled && !note.isSustainNote && daRating == "sick"));
		else
			event = scripts.event("onDadHit", EventManager.get(NoteHitEvent).recycle(false, false, false, note, strumLine.characters, false, note.noteType, note.animSuffix.getDefault(strumLine.altAnim ? "-alt" : ""), "game/score/", "", note.strumID, 0, null, 0, daRating, false));
		strumLine.onHit.dispatch(event);
		scripts.event("onNoteHit", event);

		if (!event.cancelled) {
			if (!note.isSustainNote) {
				if (event.countScore) songScore += event.score;
				if (event.accuracy != null) {
					accuracyPressedNotes++;
					totalAccuracyAmount += event.accuracy;
					updateRating();
				}
				if (event.countAsCombo) combo++;

				if (event.showRating || (event.showRating == null && event.player))
				{
					displayCombo(event);
					displayRating(daRating, event);
					ratingNum += 1;
				}
			}

			if (strumLine != null) strumLine.addHealth(event.healthGain);

			if (!event.animCancelled)
				for(char in event.characters)
					if (char != null)
						char.playSingAnim(event.direction, event.animSuffix, SING, event.forceAnim);

			if (event.note.__strum != null) {
				if (!event.strumGlowCancelled) event.note.__strum.press(event.note.strumTime);
				if (event.showSplash) splashHandler.showSplash(event.note.splash, event.note.__strum);
			}
		}

		if (event.unmuteVocals) vocals.volume = 1;
		if (event.enableCamZooming) camZooming = true;
		if (event.autoHitLastSustain) {
			if (note.nextSustain != null && note.nextSustain.nextSustain == null) {
				// its a tail!!
				note.wasGoodHit = true;
			}
		}

		if (event.deleteNote && !note.isSustainNote) strumLine.deleteNote(note);
	}

	public function displayRating(myRating:String, ?evt:NoteHitEvent = null):Void {
		var pre:String = evt != null ? evt.ratingPrefix : "";
		var suf:String = evt != null ? evt.ratingSuffix : "";

		var rating:FlxSprite = comboGroup.recycleLoop(FlxSprite);
		rating.resetSprite(comboGroup.x + -40, comboGroup.y + -60);
		rating.loadAnimatedGraphic(Paths.image('${pre}${myRating}${suf}'));
		rating.acceleration.y = 550;
		rating.velocity.y -= FlxG.random.int(140, 175);
		rating.velocity.x -= FlxG.random.int(0, 10);
		if (evt != null) {
			rating.scale.set(evt.ratingScale,evt.ratingScale);
			rating.antialiasing = evt.ratingAntialiasing;
		}
		rating.updateHitbox();

		FlxTween.tween(rating, {alpha: 0}, 0.2, {
			startDelay: Conductor.crochet * 0.001,
			onComplete: function(tween:FlxTween) {
				rating.kill();
			}
		});
	}

	public function displayCombo(?evt:NoteHitEvent = null):Void {
		var pre:String = evt != null ? evt.ratingPrefix : "";
		var suf:String = evt != null ? evt.ratingSuffix : "";
		
		var separatedScore:String = Std.string(combo).addZeros(3);

		if (combo == 0 || combo >= 10) {
			if (combo >= 10) {
				var comboSpr:FlxSprite = comboGroup.recycleLoop(FlxSprite).loadAnimatedGraphic(Paths.image('${pre}combo${suf}'));
				comboSpr.resetSprite(comboGroup.x, comboGroup.y);
				comboSpr.acceleration.y = 600;
				comboSpr.velocity.y -= 150;
				comboSpr.velocity.x += FlxG.random.int(1, 10);

				if (evt != null) {
					comboSpr.scale.set(evt.ratingScale, evt.ratingScale);
					comboSpr.antialiasing = evt.ratingAntialiasing;
				}
				comboSpr.updateHitbox();

				FlxTween.tween(comboSpr, {alpha: 0}, 0.2, {
					onComplete: function(tween:FlxTween)
					{
						comboSpr.kill();
					},
					startDelay: Conductor.crochet * 0.001
				});
			}

			for (i in 0...separatedScore.length)
			{
				var numScore:FlxSprite = comboGroup.recycleLoop(FlxSprite).loadAnimatedGraphic(Paths.image('${pre}num${separatedScore.charAt(i)}${suf}'));
				numScore.resetSprite(comboGroup.x + (43 * i) - 90, comboGroup.y + 80);
				if (evt != null) {
					numScore.antialiasing = evt.numAntialiasing;
					numScore.scale.set(evt.numScale, evt.numScale);
				}
				numScore.updateHitbox();

				numScore.acceleration.y = FlxG.random.int(200, 300);
				numScore.velocity.y -= FlxG.random.int(140, 160);
				numScore.velocity.x = FlxG.random.float(-5, 5);

				FlxTween.tween(numScore, {alpha: 0}, 0.2, {
					onComplete: function(tween:FlxTween)
					{
						numScore.kill();
					},
					startDelay: Conductor.crochet * 0.002
				});
			}
		}
	}

	public inline function deleteNote(note:Note)
		if (note.strumLine != null)
			note.strumLine.deleteNote(note);

	@:dox(hide)
	override function stepHit(curStep:Int)
	{
		super.stepHit(curStep);
		scripts.call("stepHit", [curStep]);
	}

	@:dox(hide)
	override function measureHit(curMeasure:Int)
	{
		super.measureHit(curMeasure);
		scripts.call("measureHit", [curMeasure]);
	}

	@:dox(hide)
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

		scripts.call("beatHit", [curBeat]);
	}

	public function addScript(file:String) {
		var ext = Path.extension(file).toLowerCase();
		if (Script.scriptExtensions.contains(ext))
			scripts.add(Script.create(file));
	}

	// GETTERS & SETTERS
	#if REGION
	private inline function get_player():StrumLine
		return playerStrums;
	private inline function set_player(s:StrumLine):StrumLine
		return playerStrums = s;

	private inline function get_cpu():StrumLine
		return cpuStrums;
	private inline function set_cpu(s:StrumLine):StrumLine
		return cpuStrums = s;

	private function get_boyfriend():Character {
		if (strumLines != null && strumLines.members[1] != null)
			return strumLines.members[1].characters[0];
		return null;
	}
	private function set_boyfriend(bf:Character):Character {
		if (strumLines != null && strumLines.members[1] != null)
			strumLines.members[1].characters = [bf];
		return bf;
	}
	private function get_dad():Character {
		if (strumLines != null && strumLines.members[0] != null)
			return strumLines.members[0].characters[0];
		return null;
	}
	private function set_dad(dad:Character):Character {
		if (strumLines != null && strumLines.members[0] != null)
			strumLines.members[0].characters = [dad];
		return dad;
	}
	private function get_gf():Character {
		if (strumLines != null && strumLines.members[2] != null)
			return strumLines.members[2].characters[0];
		return null;
	}
	private function set_gf(gf:Character):Character {
		if (strumLines != null && strumLines.members[2] != null)
			strumLines.members[2].characters = [gf];
		return gf;
	}
	private inline function get_cpuStrums():StrumLine
		return strumLines.members[0];
	private inline function get_playerStrums():StrumLine
		return strumLines.members[1];
	private inline function get_gfSpeed():Int
		return (strumLines.members[2] != null && strumLines.members[2].characters[0] != null) ? strumLines.members[2].characters[0].danceInterval : 1;
	private inline function set_gfSpeed(v:Int):Int {
		if (strumLines.members[2] != null && strumLines.members[2].characters[0] != null)
			strumLines.members[2].characters[0].danceInterval = v;
		return v;
	}

	private inline static function get_campaignAccuracy()
		return campaignAccuracyCount == 0 ? 0 : campaignAccuracyTotal / campaignAccuracyCount;
	#end

	/**
	 * Load a week into PlayState.
	 * @param weekData Week Data
	 * @param difficulty Week Difficulty
	 */
	public static function loadWeek(weekData:WeekData, difficulty:String = "normal") {
		storyWeek = weekData;
		storyPlaylist = [for(e in weekData.songs) e.name];
		isStoryMode = true;
		campaignScore = 0;
		campaignMisses = 0;
		campaignAccuracyTotal = 0;
		campaignAccuracyCount = 0;
		chartingMode = false;
		opponentMode = coopMode = false;
		__loadSong(storyPlaylist[0], difficulty);
	}

	/**
	 * Loads a song into PlayState
	 * @param name Song name
	 * @param difficulty Chart difficulty (if invalid, will load an empty chart)
	 * @param opponentMode Whenever opponent mode is on
	 * @param coopMode Whenever co-op mode is on.
	 */
	public static function loadSong(name:String, difficulty:String = "normal", opponentMode:Bool = false, coopMode:Bool = false) {
		isStoryMode = false;
		PlayState.opponentMode = opponentMode;
		chartingMode = false;
		PlayState.coopMode = coopMode;
		__loadSong(name, difficulty);
	}

	/**
	 * (INTERNAL) Loads a song without resetting story mode/opponent mode/coop mode values.
	 * @param name Song name
	 * @param difficulty Song difficulty
	 */
	public static function __loadSong(name:String, difficulty:String) {
		PlayState.difficulty = difficulty;

		PlayState.SONG = Chart.parse(name, difficulty);
		PlayState.fromMods = PlayState.SONG.fromMods;
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

typedef PlayStateTransitionData = {
	var stage:String;
	var camX:Float;
	var camY:Float;
	var camFollowX:Float;
	var camFollowY:Float;
	var camZoom:Float;
}
