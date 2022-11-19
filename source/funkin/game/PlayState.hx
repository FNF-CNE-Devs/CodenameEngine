package funkin.game;

import funkin.scripting.DummyScript;
import funkin.menus.StoryMenuState.WeekData;
import funkin.ui.FunkinText;
import flixel.group.FlxSpriteGroup;
import funkin.options.Options;
import funkin.scripting.Script;
import flixel.util.FlxDestroyUtil;
#if desktop
import funkin.system.Discord.DiscordClient;
#end
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
	public static var instance:PlayState = null;

	/**
	 * SONG METADATA
	 */
	public static var SONG:SwagSong;
	public static var isStoryMode:Bool = false;
	public static var storyWeek:WeekData = null;
	public static var storyPlaylist:Array<String> = [];
	public static var difficulty:String = "normal";
	public static var fromMods:Bool = false;

	public var scripts:ScriptPack;
	public var halloweenLevel:Bool = false;

	public var stage:Stage;
	public var scrollSpeed:Float = 0;
	public var downscroll(get, set):Bool;

	@:dox(hide) private function set_downscroll(v:Bool) {return camHUD.downscroll = v;}
	@:dox(hide) private function get_downscroll():Bool  {return camHUD.downscroll;}

	public var inst:FlxSound;
	public var vocals:FlxSound;

	public var dad:Character;
	public var gf:Character;
	public var boyfriend:Character;

	public var notes:NoteGroup;

	public var strumLine:FlxObject;
	public var ratingNum:Int = 0;

	public var camFollow:FlxObject;

	private static var prevCamFollow:FlxObject;

	public var strumLineNotes:FlxTypedGroup<Strum>;
	public var playerStrums:FlxTypedGroup<Strum>;
	public var cpuStrums:FlxTypedGroup<Strum>;

	public var muteVocalsOnMiss:Bool = true;

	public var camZooming:Bool = false;
	public var camZoomingInterval:Int = 4;
	public var curSong:String = "";
	public var curStage:String = "";

	public var gfSpeed:Int = 1;
	public var health:Float = 1;
	public var combo:Int = 0;

	public var comboBreaks:Bool = false;
	public var healthBarBG:FlxSprite;
	public var healthBar:FlxBar;

	public var generatedMusic:Bool = false;
	public var startingSong:Bool = false;

	public var iconP1:HealthIcon;
	public var iconP2:HealthIcon;
	public var camHUD:HudCamera;
	public var camGame:FlxCamera;

	
	public var songScore:Int = 0;
	public var misses:Int = 0;
	public var accuracy(get, set):Float;

	private function get_accuracy():Float {
		if (accuracyPressedNotes <= 0) return -1;
		return totalAccuracyAmount / accuracyPressedNotes;
	}
	private function set_accuracy(v:Float):Float {
		if (accuracyPressedNotes <= 0)
			accuracyPressedNotes = 1;
		return totalAccuracyAmount = v * accuracyPressedNotes;
	}
	public var accuracyPressedNotes:Float = 0;
	public var totalAccuracyAmount:Float = 0;

	public var scoreTxt:FunkinText;
	public var missesTxt:FunkinText;
	public var accuracyTxt:FunkinText;

	public static var campaignScore:Int = 0;

	public var defaultCamZoom:Float = 1.05;

	// how big to stretch the pixel art assets
	public static var daPixelZoom:Float = 6;

	public var inCutscene:Bool = false;

	public var comboRatings:Array<ComboRating> = [
		new ComboRating(0, "F", 0xFFFF4444),
		new ComboRating(0.1, "E", 0xFFFF8844),
		new ComboRating(0.2, "D", 0xFFFFAA44),
		new ComboRating(0.4, "C", 0xFFFFFF44),
		new ComboRating(0.6, "B", 0xFFAAFF44),
		new ComboRating(0.8, "A", 0xFF88FF44),
		new ComboRating(0.9, "S", 0xFF44FFFF),
		new ComboRating(1, "S++", 0xFF44FFFF),
	];

	#if desktop
	// Discord RPC variables
	public var difficultyText:String = "";
	public var iconRPC:String = "";
	public var songLength:Float = 0;
	public var detailsText:String = "";
	public var detailsPausedText:String = "";
	#end

	public var curRating:ComboRating;

	public function updateRating() {
		var rating = null;
		var acc = get_accuracy();

		for(e in comboRatings) {
			if (e.percent <= acc && (rating == null || rating.percent < e.percent))
				rating = e;
		}

		var event = scripts.event("onRatingUpdate", new RatingUpdateEvent(rating, curRating));
		if (!event.cancelled)
			curRating = event.rating;
	}

	override public function create()
	{
		instance = this;
		PauseSubState.script = "";

		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		scripts = new ScriptPack("PlayState");
		scripts.setParent(this);

		camGame = camera;
		camHUD = new HudCamera();
		camHUD.bgColor.alpha = 0;

		FlxG.cameras.add(camHUD, false);

		downscroll = Options.downscroll;
		// camGame.widescreen = true;

		persistentUpdate = true;
		persistentDraw = true;

		if (SONG == null)
			SONG = Song.loadFromJson('tutorial', 'normal');

		scrollSpeed = SONG.speed;

		Conductor.reset();
		Conductor.mapBPMChanges(SONG);
		Conductor.changeBPM(SONG.bpm);

		#if desktop
		// TODO: Scriptable custom RPC
		iconRPC = SONG.player2;

		// String that contains the mode defined here so it isn't necessary to call changePresence for each mode
		if (isStoryMode)
		{
			detailsText = "Story Mode: " + storyWeek.name;
		}
		else
		{
			detailsText = "Freeplay";
		}

		// Checks if cutscene files exists
		var cutscenePath = Paths.script('data/cutscenes/${SONG.song.toLowerCase()}');
		var endCutscenePath = Paths.script('data/cutscenes/${SONG.song.toLowerCase()}-end');
		if (Assets.exists(cutscenePath))
			cutscene = cutscenePath;
		if (Assets.exists(endCutscenePath))
			endCutscene = endCutscenePath;

		// String for when the game is paused
		detailsPausedText = "Paused - " + detailsText;
		
		// Updating Discord Rich Presence.
		DiscordClient.changePresence(detailsText, SONG.song + " (" + difficultyText + ")", iconRPC);
		#end
		dad = new Character(100, 100, SONG.player2);


		if (dad != null && dad.isGF) {
			dad.setPosition(400, 130);
			gf = dad;
			dad.scrollFactor.set(0.95, 0.95);
		} else {
			var gfVersion = SONG.gf;
			if (gfVersion == null) gfVersion = "gf";
			gf = new Character(400, 130, gfVersion);
			gf.scrollFactor.set(0.95, 0.95);
		}

		var camPos:FlxPoint = new FlxPoint(dad.getGraphicMidpoint().x, dad.getGraphicMidpoint().y);


		comboGroup = new FlxSpriteGroup(FlxG.width * 0.55, (FlxG.height * 0.5) - 60);

		boyfriend = new Character(770, 100, SONG.player1, true);


		if (SONG.stage == null || SONG.stage.trim() == "") SONG.stage = "stage";
		add(new Stage(SONG.stage));

		
		switch(SONG.song) {
			// case "":
				// ADD YOUR HARDCODED SCRIPTS HERE!
			default:
				for(content in [
					Paths.getFolderContent('data/charts/${SONG.song}/', false, true, !fromMods),
					Paths.getFolderContent('data/charts/', false, true, !fromMods)]) {
					for(file in content) {
						var ext = Path.extension(file).toLowerCase();
						if (Script.scriptExtensions.contains(ext)) {
							scripts.add(Script.create(file));
						}
					}
				}
		}

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
			'health', 0, 2);
		healthBar.scrollFactor.set();
		healthBar.createFilledBar(0xFFFF0000, 0xFF66FF33);
		add(healthBar);


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

	// PATH TO STRING CUTSCENE (Paths.script
	public var playCutscenes:Bool = isStoryMode;
	public var cutscene:String = null;
	public var endCutscene:String = null;
	public override function createPost() {
		startCutscene();
		super.createPost();
		scripts.call("postCreate");
	}

	public function startCutscene() {
		if (playCutscenes) {
			var videoCutscene = Paths.video('${PlayState.SONG.song.toLowerCase()}-cutscene');
			persistentUpdate = false;
			if (cutscene != null) {
				openSubState(new ScriptedCutscene(cutscene, function() {
					startCountdown();
				}));
			} else if (Assets.exists(videoCutscene)) {
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
			persistentUpdate = false;
			if (endCutscene != null) {
				openSubState(new ScriptedCutscene(endCutscene, function() {
					nextSong();
				}));
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

	public var startTimer:FlxTimer;
	public var perfectMode:Bool = false;
	public var introLength:Int = 5;
	public var introSprites:Array<String> = [null, 'game/ready', "game/set", "game/go"];
	public var introSounds:Array<String> = ['intro3', 'intro2', "intro1", "introGo"];

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
			dad.dance();
			gf.dance();
			boyfriend.dance();

			countdown(swagCounter);

			swagCounter += 1;
		}, introLength);
	}

	/**
	 * Creates a fake countdown.
	 */
	public function countdown(swagCounter:Int) {
		var event:CountdownEvent = scripts.event("onCountdown", new CountdownEvent(
			swagCounter, 
			introSprites[swagCounter],
			introSounds[swagCounter],
			1, 0.6, true));

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

	public var previousFrameTime:Int = 0;
	public var lastReportedPlayheadPosition:Int = 0;
	public var songTime:Float = 0;

	function startSong():Void
	{
		startingSong = false;

		previousFrameTime = FlxG.game.ticks;
		lastReportedPlayheadPosition = 0;

		if (!paused) {
			FlxG.sound.music = inst;
			FlxG.sound.music.play();
		}
		FlxG.sound.music.onComplete = endSong;
		vocals.play();

		updateDiscordStatus();
	}

	public override function destroy() {
		scripts.call("destroy");
		super.destroy();
		FlxDestroyUtil.destroy(scripts);
		instance = null;
		if (vocals != null) {
			vocals.destroy();
		}
	}

	public var debugNum:Int = 0;

	public function generateNotes(songData:SwagSong) {
		if (songData == null) return;
		if (songData.noteTypes == null) songData.noteTypes = [];

		var noteData:Array<SwagSection> = songData.notes;
		var playerCounter:Int = 0;
		var daBeats:Int = 0; // Not exactly representative of 'daBeats' lol, just how much it has looped
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
			}
			daBeats += 1;
		}
		notes.sortNotes();
	}
	private function generateSong(?songData:SwagSong):Void
	{
		if (songData == null) songData = SONG;

		Conductor.changeBPM(songData.bpm);

		curSong = songData.song;

		inst = FlxG.sound.load(Paths.inst(PlayState.SONG.song));
		vocals = new FlxSound();
		if (SONG.needsVoices)
			vocals.loadEmbedded(Paths.voices(PlayState.SONG.song));
		FlxG.sound.list.add(vocals);

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

			var event = scripts.event("onStrumCreation", new StrumCreationEvent(babyArrow, player, i));

			if (!event.cancelled) {
				switch (curStage)
				{
					// case "school":
					default:
						babyArrow.frames = Paths.getSparrowAtlas('game/NOTE_assets');
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

	function tweenCamIn():Void
	{
		FlxTween.tween(FlxG.camera, {zoom: 1.3}, (Conductor.stepCrochet * 4 / 1000), {ease: FlxEase.elasticInOut});
	}

	override function openSubState(SubState:FlxSubState)
	{
		var event = scripts.event("onSubstateOpen", new StateEvent(SubState));

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
		var event = scripts.event("onSubstateClose", new StateEvent(subState));
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

			#if desktop
			if (startTimer.finished)
			{
				DiscordClient.changePresence(detailsText, SONG.song + " (" + difficultyText + ")", iconRPC, true, songLength - Conductor.songPosition);
			}
			else
			{
				DiscordClient.changePresence(detailsText, SONG.song + " (" + difficultyText + ")", iconRPC);
			}
			#end
		}

		super.closeSubState();
	}

	override public function onFocus():Void
	{
		scripts.call("onFocus");
		#if desktop
		if (health > 0 && !paused)
		{
			if (Conductor.songPosition > 0.0)
			{
				DiscordClient.changePresence(detailsText, SONG.song + " (" + difficultyText + ")", iconRPC, true, songLength - Conductor.songPosition);
			}
			else
			{
				DiscordClient.changePresence(detailsText, SONG.song + " (" + difficultyText + ")", iconRPC);
			}
		}
		#end

		super.onFocus();
	}
	
	override public function onFocusLost():Void
	{
		scripts.call("onFocusLost");
		#if desktop
		if (health > 0 && !paused)
		{
			DiscordClient.changePresence(detailsPausedText, SONG.song + " (" + difficultyText + ")", iconRPC);
		}
		#end

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

	public var paused:Bool = false;
	public var startedCountdown:Bool = false;
	public var canPause:Bool = true;


	public function pauseGame() {
		// TODO: Cancellable game pause
		scripts.call("onGamePause");
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
	
		updateDiscordStatus();
	}

	// TODO: Update Discord Status
	public function updateDiscordStatus() {
		// TODO: Cancellable Discord Update Presence
		#if desktop
		// Song duration in a float, useful for the time left feature
		songLength = inst.length;

		// Updating Discord Rich Presence (with Time Left)
		DiscordClient.changePresence(detailsText, SONG.song + " (" + difficultyText + ")", iconRPC, true, songLength);
		#end
		scripts.call("onDiscordPresenceUpdate");
	}

	var __vocalOffsetViolation:Float = 0;
	public var accFormat:FlxTextFormat = new FlxTextFormat(0xFF888888, false, false, 0);
	override public function update(elapsed:Float)
	{
		#if !debug
		perfectMode = false;
		#end

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

		if (FlxG.keys.justPressed.SEVEN)
		{
			FlxG.switchState(new ChartingState());

			#if desktop
			DiscordClient.changePresence("Chart Editor", null, null, true);
			#end
		}
		if (FlxG.keys.justPressed.F5) {
			Logs.trace('Reloading scripts...', WARNING, YELLOW);
			scripts.reload();
			Logs.trace('Song scripts successfully reloaded.', WARNING, GREEN);
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

		if (health > 2)
			health = 2;

		iconP1.health = healthBar.percent / 100;
		iconP2.health = 1 - (healthBar.percent / 100);
		
		/* if (FlxG.keys.justPressed.NINE)
			FlxG.switchState(new Charting()); */

		if (FlxG.keys.justPressed.EIGHT)
			FlxG.switchState(new AnimationDebug(SONG.player2));

		if (startingSong)
		{
			if (startedCountdown)
			{
				Conductor.songPosition += FlxG.elapsed * 1000;
				if (Conductor.songPosition >= 0)
					startSong();
			}
		} else {
			__vocalOffsetViolation = Math.max(0, __vocalOffsetViolation + (FlxG.sound.music.time != vocals.time ? elapsed * 2 : -elapsed));
			if (__vocalOffsetViolation > 25) {
				resyncVocals();
				__vocalOffsetViolation = 0;
			}
		}

		if (generatedMusic && PlayState.SONG.notes[Std.int(curStep / 16)] != null)
		{
			if (PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection)
			{
				var pos = boyfriend.getCameraPosition();
				camFollow.setPosition(pos.x, pos.y);

				// switch (curStage)
				// {
				// 	case 'limo':
				// 		camFollow.x = boyfriend.getMidpoint().x - 300;
				// 	case 'mall':
				// 		camFollow.y = boyfriend.getMidpoint().y - 200;
				// 	case 'school':
				// 		camFollow.x = boyfriend.getMidpoint().x - 200;
				// 		camFollow.y = boyfriend.getMidpoint().y - 200;
				// 	case 'schoolEvil':
				// 		camFollow.x = boyfriend.getMidpoint().x - 200;
				// 		camFollow.y = boyfriend.getMidpoint().y - 200;
				// }
				
				if (SONG.song.toLowerCase() == 'tutorial')
				{
					FlxTween.tween(FlxG.camera, {zoom: 1}, (Conductor.stepCrochet * 4 / 1000), {ease: FlxEase.elasticInOut});
				}
			} else {
				var pos = dad.getCameraPosition();
				camFollow.setPosition(pos.x, pos.y);

				// camFollow.setPosition(dad.getMidpoint().x + 150, dad.getMidpoint().y - 100);
				// camFollow.setPosition(lucky.getMidpoint().x - 120, lucky.getMidpoint().y + 210);

				// switch (dad.curCharacter)
				// {
				// 	case 'mom':
				// 		camFollow.y = dad.getMidpoint().y;
				// 	case 'senpai':
				// 		camFollow.y = dad.getMidpoint().y - 430;
				// 		camFollow.x = dad.getMidpoint().x - 100;
				// 	case 'senpai-angry':
				// 		camFollow.y = dad.getMidpoint().y - 430;
				// 		camFollow.x = dad.getMidpoint().x - 100;
				// }

				if (dad.curCharacter == 'mom')
					vocals.volume = 1;

				if (SONG.song.toLowerCase() == 'tutorial')
				{
					tweenCamIn();
				}
			}
		}

		if (camZooming)
		{
			FlxG.camera.zoom = lerp(FlxG.camera.zoom, defaultCamZoom, 0.05);
			camHUD.zoom = lerp(camHUD.zoom, 1, 0.05);
		}

		FlxG.watch.addQuick("beatShit", curBeat);
		FlxG.watch.addQuick("stepShit", curStep);

		if (curSong == 'Fresh')
		{
			switch (curBeat)
			{
				case 16:
					camZooming = true;
					gfSpeed = 2;
				case 48:
					gfSpeed = 1;
				case 80:
					gfSpeed = 2;
				case 112:
					gfSpeed = 1;
				case 163:
					// FlxG.sound.music.stop();
					// FlxG.switchState(new TitleState());
			}
		}

		if (curSong == 'Bopeebo')
		{
			switch (curBeat)
			{
				case 128, 129, 130:
					vocals.volume = 0;
					// FlxG.sound.music.stop();
					// FlxG.switchState(new PlayState());
			}
		}
		// better streaming of shit

		// RESET = Quick Game Over Screen
		if (controls.RESET)
		{
			health = 0;
			trace("RESET = True");
		}

		// CHEAT = brandon's a pussy
		if (controls.CHEAT)
		{
			health += 1;
			trace("User is cheating!");
		}

		if (health <= 0)
		{
			boyfriend.stunned = true;

			persistentUpdate = false;
			persistentDraw = false;
			paused = true;

			vocals.stop();
			FlxG.sound.music.stop();

			openSubState(new GameOverSubstate(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));

			// FlxG.switchState(new GameOverState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
			
			#if desktop
			// Game Over doesn't get his own variable because it's only used here
			DiscordClient.changePresence("Game Over - " + detailsText, SONG.song + " (" + difficultyText + ")", iconRPC);
			#end
		}

		// while(unspawnNotes[0] != null && unspawnNotes[0].strumTime - Conductor.songPosition < 1500)
		// 	notes.add(unspawnNotes.shift());
		


		if (generatedMusic)
		{
			notes.forEachAlive(function(daNote:Note)
			{
				var strum:Strum = null;
				for(e in (daNote.mustPress ? playerStrums : cpuStrums).members) {
					if (e.ID == daNote.noteData % 4) {
						strum = e;
						break; //ing bad
					}
				}
				
				var event = PlayState.instance.scripts.event("onNoteUpdate", new NoteUpdateEvent(daNote, elapsed, strum));
				if (!event.cancelled) {
					if (event.__updateHitWindow) {
						if (daNote.mustPress)
						{
							daNote.canBeHit = (daNote.strumTime > Conductor.songPosition - (Conductor.safeZoneOffset * daNote.latePressWindow)
								&& daNote.strumTime < Conductor.songPosition + (Conductor.safeZoneOffset * daNote.earlyPressWindow));
		
							if (daNote.strumTime < Conductor.songPosition - Conductor.safeZoneOffset && !daNote.wasGoodHit)
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
				
			});
		}

		if (!inCutscene)
			keyShit();

		#if debug
		if (FlxG.keys.justPressed.ONE)
			endSong();
		#end
		
		scripts.call("postUpdate", [elapsed]);
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
			// TODO: Accuracy stuff
			Highscore.saveScore(SONG.song, {
				score: songScore,
				misses: misses
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

				transIn = FlxTransitionableState.defaultTransIn;
				transOut = FlxTransitionableState.defaultTransOut;

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

				if (SONG.song.toLowerCase() == 'eggnog')
				{
					var blackShit:FlxSprite = new FlxSprite(-FlxG.width * FlxG.camera.zoom,
						-FlxG.height * FlxG.camera.zoom).makeGraphic(FlxG.width * 3, FlxG.height * 3, FlxColor.BLACK);
					blackShit.scrollFactor.set();
					add(blackShit);
					camHUD.visible = false;

					FlxG.sound.play(Paths.sound('Lights_Shut_off'));
				}

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

	public var endingSong:Bool = false;

	public var comboGroup:FlxSpriteGroup;

	private function keyShit():Void
	{
		var pressed = [controls.NOTE_LEFT, controls.NOTE_DOWN, controls.NOTE_UP, controls.NOTE_RIGHT];
		var justPressed = [controls.NOTE_LEFT_P, controls.NOTE_DOWN_P, controls.NOTE_UP_P, controls.NOTE_RIGHT_P];
		var justReleased = [controls.NOTE_LEFT_R, controls.NOTE_DOWN_R, controls.NOTE_UP_R, controls.NOTE_RIGHT_R];

		var event = scripts.event("onKeyShit", new InputSystemEvent(pressed, justPressed, justReleased));
		if (event.cancelled) return;
		pressed = CoolUtil.getDefault(event.pressed, []);
		justPressed = CoolUtil.getDefault(event.justPressed, []);
		justReleased = CoolUtil.getDefault(event.justReleased, []);

		var funcsToExec:Array<Note->Void> = [];
		if (pressed.contains(true)) {
			funcsToExec.push(function(note:Note) {
				if (pressed[note.strumID] && note.isSustainNote && note.canBeHit && note.mustPress && !note.wasGoodHit) {
					goodNoteHit(note);
				}
			});
		}

		var notePerStrum = [for(i in 0...4) null];
		var additionalNotes:Array<Note> = [];
		if (justPressed.contains(true)) {
			funcsToExec.push(function(note:Note) {
				if (justPressed[note.strumID] && !note.isSustainNote && note.mustPress && !note.wasGoodHit && note.canBeHit) {
					if (notePerStrum[note.strumID] == null) 										notePerStrum[note.strumID] = note;
					else if (Math.abs(notePerStrum[note.strumID].strumTime - note.strumTime) <= 10) additionalNotes.push(note);
					else if (note.strumTime < notePerStrum[note.strumID].strumTime)					notePerStrum[note.strumID] = note;
				}
			});
		}

		if (funcsToExec.length > 0) {
			notes.forEachAlive(function(note:Note) {
				for(e in funcsToExec) e(note);
			});
		}

		for(e in notePerStrum) if (e != null) goodNoteHit(e);
		for(e in additionalNotes) goodNoteHit(e);

		playerStrums.forEach(function(str:Strum) {
			str.updatePlayerInput(pressed[str.ID], justPressed[str.ID], justReleased[str.ID]);
		});
		scripts.call("onPostKeyShit");
	}

	function noteMiss(note:Note):Void
	{
		if (!boyfriend.stunned)
		{
			var event:NoteHitEvent = scripts.event("onPlayerMiss", new NoteHitEvent(note, boyfriend, true, note.noteType, note.strumID, -0.04, false, -10));

			if (event.cancelled) return;
			
			health += event.healthGain;
			if (combo > 5 && gf.animOffsets.exists('sad'))
			{
				gf.playAnim('sad');
			}
			combo = 0;

			songScore -= 10;
			misses++;

			FlxG.sound.play(Paths.soundRandom('missnote', 1, 3), FlxG.random.float(0.1, 0.2));

			if (muteVocalsOnMiss) vocals.volume = 0;
			boyfriend.stunned = true;

			switch (note.strumID)
			{
				case 0:
					boyfriend.playAnim('singLEFTmiss', true, MISS);
				case 1:
					boyfriend.playAnim('singDOWNmiss', true, MISS);
				case 2:
					boyfriend.playAnim('singUPmiss', true, MISS);
				case 3:
					boyfriend.playAnim('singRIGHTmiss', true, MISS);
			}
			deleteNote(note);
		}
	}

	public var noteTypesArray:Array<String> = [null];
	public function getNoteType(id:Int):String {
		return noteTypesArray[id];
	}

	function goodNoteHit(note:Note):Void
	{
		if (!note.wasGoodHit)
		{
			note.wasGoodHit = true;
			
			/**
			 * CALCULATES RATING
			 */
			var noteDiff = Math.abs(Conductor.songPosition - note.strumTime);
			var daRating:String = "sick";
			var score:Int = 300;
			var accuracy:Float = 1;
	
			if (noteDiff > Conductor.safeZoneOffset * 0.9)
			{
				daRating = 'shit';
				score = 50;
				accuracy = 0.25;
			}
			else if (noteDiff > Conductor.safeZoneOffset * 0.75)
			{
				daRating = 'bad';
				score = 100;
				accuracy = 0.45;
			}
			else if (noteDiff > Conductor.safeZoneOffset * 0.2)
			{
				daRating = 'good';
				score = 200;
				accuracy = 0.75;
			}

			var event:NoteHitEvent;
			if (note.mustPress)
				event = scripts.event("onPlayerHit", new NoteHitEvent(note, boyfriend, true, note.noteType, note.strumID, note.noteData > 0 ? 0.023 : 0.004, score, note.animSuffix, daRating, note.isSustainNote ? null : accuracy, "game/score/", ''));
			else
				event = scripts.event("onDadHit", new NoteHitEvent(note, dad, false, note.noteType, note.strumID, 0, 0, note.animSuffix, daRating, null, "game/score/", ''));
			
			if (!event.cancelled) {
				if (event.accuracy != null) {
					accuracyPressedNotes++;
					totalAccuracyAmount += accuracy;

					updateRating();
				}
				if (event.countAsCombo) combo++;

				if (event.showRating || (event.showRating == null && event.player && !note.isSustainNote))
				{
					var rating:FlxSprite = new FlxSprite(-40, -60);
			
					songScore += score;
			
					rating.loadAnimatedGraphic(Paths.image('${event.ratingPrefix}$daRating${event.ratingSuffix}'));
					rating.acceleration.y = 550;
					rating.velocity.y -= FlxG.random.int(140, 175);
					rating.velocity.x -= FlxG.random.int(0, 10);
			
					var comboSpr:FlxSprite = new FlxSprite().loadAnimatedGraphic(Paths.image('${event.ratingPrefix}combo${event.ratingSuffix}'));
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
							var e = separatedScore.charAt(i);
				
							var numScore:FlxSprite = new FlxSprite((43 * i) - 90, 80).loadAnimatedGraphic(Paths.image('${event.ratingPrefix}num$e${event.ratingSuffix}'));
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
									comboGroup.remove(numScore, true);
									numScore.destroy();
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
							comboGroup.remove(comboSpr, true);
							comboGroup.remove(rating, true);
							comboSpr.destroy();
			
							rating.destroy();
						},
						startDelay: Conductor.crochet * 0.001
					});
			
					ratingNum += 1;
				}

				health += event.healthGain;
	
				if (!event.animCancelled) {
					event.character.playSingAnim(event.direction, event.animSuffix);
				}
	
				if (!event.strumGlowCancelled) (event.player ? playerStrums : cpuStrums).forEach(function(str:Strum) {
					if (str.ID == Math.abs(note.strumID)) {
						str.press(note.strumTime);
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
	}

	public function deleteNote(note:Note) {
		var event:SimpleNoteEvent = scripts.event("onNoteDelete", new SimpleNoteEvent(note));
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
		scripts.call("beatHit", [curBeat]);
		
		if (camZoomingInterval < 1) camZoomingInterval = 1;
		if (Options.camZoomOnBeat && camZooming && FlxG.camera.zoom < 1.35 && curBeat % camZoomingInterval == 0)
		{
			FlxG.camera.zoom += 0.015;
			camHUD.zoom += 0.03;
		}

		iconP1.scale.set(1.2, 1.2);
		iconP2.scale.set(1.2, 1.2);

		iconP1.updateHitbox();
		iconP2.updateHitbox();

		if (curBeat % gfSpeed == 0)
		{
			gf.dance();
		}
	}

	public var curLight:Int = 0;
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