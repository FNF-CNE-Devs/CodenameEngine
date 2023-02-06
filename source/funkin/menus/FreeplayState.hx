package funkin.menus;

import haxe.io.Path;
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import lime.utils.Assets;
import funkin.system.Song;
import funkin.ui.Alphabet;
import funkin.game.HealthIcon;
import funkin.game.Highscore;
import haxe.Json;
import funkin.scripting.events.*;

using StringTools;

class FreeplayState extends MusicBeatState
{
	/**
	 * Default background colors for songs without bg color
	 */
	public inline static var defaultColor:FlxColor = 0xFF9271FD;

	/**
	 * How much time a song stays selected until it autoplays.
	 */
	public inline static var timeUntilAutoplay:Float = 1;

	/**
	 * Array containing all of the songs metadatas
	 */
	public var songs:Array<SongMetadata> = [];

	/**
	 * Currently selected song
	 */
	public var curSelected:Int = 0;
	/**
	 * Currently selected difficulty
	 */
	public var curDifficulty:Int = 1;
	/**
	 * Currently selected coop/opponent mode
	 */
	public var curCoopMode:Int = 0;

	/**
	 * Text containing the score info (PERSONAL BEST: 0)
	 */
	public var scoreText:FlxText;
	
	/**
	 * Text containing the current difficulty (< HARD >)
	 */
	public var diffText:FlxText;
	
	/**
	 * Text containing the current coop/opponent mode ([TAB] Co-Op mode)
	 */
	public var coopText:FlxText;
	
	/**
	 * Currently lerped score. Is updated to go towards `intendedScore`.
	 */
	public var lerpScore:Int = 0;
	/**
	 * Destination for the currently lerped score.
	 */
	public var intendedScore:Int = 0;

	/**
	 * Assigned FreeplaySonglist item.
	 */
	public var songList:FreeplaySonglist;
	/**
	 * Black background around the score, the difficulty text and the co-op text.
	 */
	public var scoreBG:FlxSprite;

	/**
	 * Background.
	 */
	public var bg:FlxSprite;

	/**
	 * Whenever the player can navigate and select
	 */
	public var canSelect:Bool = true;

	/**
	 * Group containing all of the alphabets
	 */
	public var grpSongs:FlxTypedGroup<Alphabet>;

	/**
	 * Whenever the currently selected song is playing.
	 */
	public var curPlaying:Bool = false;

	/**
	 * Array containing all of the icons.
	 */
	public var iconArray:Array<HealthIcon> = [];

	override function create()
	{
		songList = FreeplaySonglist.get();
		songs = songList.songs;

		DiscordUtil.changePresence("In the Menus", null);

		// LOAD CHARACTERS

		bg = new FlxSprite(0, 0).loadAnimatedGraphic(Paths.image('menus/menuDesat'));
		if (songs.length > 0)
			bg.color = songs[0].color;
		add(bg);

		grpSongs = new FlxTypedGroup<Alphabet>();
		add(grpSongs);

		for (i in 0...songs.length)
		{
			var songText:Alphabet = new Alphabet(0, (70 * i) + 30, songs[i].songName, true, false);
			songText.isMenuItem = true;
			songText.targetY = i;
			grpSongs.add(songText);

			var icon:HealthIcon = new HealthIcon(songs[i].songCharacter);
			icon.sprTracker = songText;

			// using a FlxGroup is too much fuss!
			iconArray.push(icon);
			add(icon);

			// songText.x += 40;
			// DONT PUT X IN THE FIRST PARAMETER OF new ALPHABET() !!
			// songText.screenCenter(X);
		}

		scoreText = new FlxText(FlxG.width * 0.7, 5, 0, "", 32);
		scoreText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, RIGHT);

		scoreBG = new FlxSprite(scoreText.x - 6, 0).makeGraphic(1, 1, 0xFF000000);
		scoreBG.alpha = 0.6;
		add(scoreBG);

		diffText = new FlxText(scoreText.x, scoreText.y + 36, 0, "", 24);
		diffText.font = scoreText.font;
		add(diffText);

		coopText = new FlxText(diffText.x, diffText.y + diffText.height + 2, 0, "[TAB] Solo", 24);
		coopText.font = scoreText.font;
		add(coopText);

		add(scoreText);

		changeSelection(0, true);
		changeDiff(0, true);
		changeCoopMode(0, true);

		super.create();
	}

	#if PRELOAD_ALL
	/**
	 * Time elapsed since last autoplay. If this time exceeds `timeUntilAutoplay`, the currently selected song will play.
	 */
	public var autoplayElapsed:Float = 0;
	/**
	 * Whenever the currently selected song instrumental is playing.
	 */
	public var songInstPlaying:Bool = true;
	/**
	 * Path to the currently playing song instrumental.
	 */
	public var curPlayingInst:String = null;
	#end

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (FlxG.sound.music != null && FlxG.sound.music.volume < 0.7)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		lerpScore = Math.floor(lerp(lerpScore, intendedScore, 0.4));

		if (Math.abs(lerpScore - intendedScore) <= 10)
			lerpScore = intendedScore;

		if (canSelect) {
			changeSelection((controls.UP_P ? -1 : 0) + (controls.DOWN_P ? 1 : 0));
			changeDiff((controls.LEFT_P ? -1 : 0) + (controls.RIGHT_P ? 1 : 0));
			changeCoopMode((FlxG.keys.justPressed.TAB ? 1 : 0));
			// putting it before so that its actually smooth
			updateOptionsAlpha();
		}

		scoreText.text = "PERSONAL BEST:" + lerpScore;
		scoreBG.scale.set(Math.max(diffText.width, scoreText.width) + 8, (coopText.visible ? coopText.y + coopText.height : 66));
		scoreBG.updateHitbox();
		scoreBG.x = FlxG.width - scoreBG.width;

		scoreText.x = coopText.x = scoreBG.x + 4;
		diffText.x = Std.int(scoreBG.x + ((scoreBG.width - diffText.width) / 2));

		bg.color = CoolUtil.lerpColor(bg.color, songs[curSelected].color, 0.0625);


		var dontPlaySongThisFrame = false;
		#if PRELOAD_ALL
		autoplayElapsed += elapsed;
		if (!songInstPlaying && (autoplayElapsed > timeUntilAutoplay || FlxG.keys.justPressed.SPACE)) {
			if (curPlayingInst != (curPlayingInst = Paths.inst(songs[curSelected].songName, songs[curSelected].difficulties[curDifficulty])))
				FlxG.sound.playMusic(curPlayingInst, 0);
			songInstPlaying = true;
			dontPlaySongThisFrame = true;
		}
		#end


		if (controls.BACK)
		{
			CoolUtil.playMenuSFX(CANCEL, 0.7);
			FlxG.switchState(new MainMenuState());
		}

		if (controls.ACCEPT && !dontPlaySongThisFrame)
			select();
	}

	/**
	 * Selects the current song.
	 */
	public function select() {
		var opponentMode:Bool = false;
		var coopMode:Bool = false;
		if (songs[curSelected].coopAllowed && songs[curSelected].opponentModeAllowed) {
			opponentMode = curCoopMode % 2 == 1;
			coopMode = curCoopMode >= 2;
		} else if (songs[curSelected].coopAllowed) {
			coopMode = curCoopMode == 1;
		} else if (songs[curSelected].opponentModeAllowed) {
			opponentMode = curCoopMode == 1;
		}

		var event = event("onSelect", EventManager.get(FreeplaySongSelectEvent).recycle(songs[curSelected].songName, songs[curSelected].difficulties[curDifficulty], opponentMode, coopMode));

		if (event.cancelled) return;

		CoolUtil.loadSong(event.song, event.difficulty, event.opponentMode, event.coopMode);
		FlxG.switchState(new PlayState());
	}

	/**
	 * Changes the current difficulty
	 * @param change How much to change.
	 * @param force Force the change if `change` is equal to 0
	 */
	public function changeDiff(change:Int = 0, force:Bool = false)
	{
		if (change == 0 && !force) return;

		var curSong = songs[curSelected];
		var event = event("onChangeDiff", EventManager.get(MenuChangeEvent).recycle(curDifficulty, FlxMath.wrap(curDifficulty + change, 0, curSong.difficulties.length-1), change));

		if (event.cancelled) return;

		curDifficulty = event.value;

		#if !switch
		intendedScore = Highscore.getScore(curSong.songName, curSong.difficulties[curDifficulty]).score;
		#end

		if (curSong.difficulties.length > 1)
			diffText.text = '< ${curSong.difficulties[curDifficulty]} >';
		else
			diffText.text = curSong.difficulties[curDifficulty];
	}

	/**
	 * Array containing all labels for Co-Op / Opponent modes.
	 */
	public var coopLabels:Array<String> = [
		"[TAB] Solo",
		"[TAB] Opponent Mode",
		"[TAB] Co-Op Mode",
		"[TAB] Co-Op Mode (Switched)"
	];

	/**
	 * Change the current coop mode context.
	 * @param change How much to change
	 * @param force Force the change, even if `change` is equal to 0.
	 */
	 public function changeCoopMode(change:Int = 0, force:Bool = false) {
		if (change == 0 && !force) return;
		if (!songs[curSelected].coopAllowed && !songs[curSelected].opponentModeAllowed) return;

		var bothEnabled = songs[curSelected].coopAllowed && songs[curSelected].opponentModeAllowed;
		var event = event("onChangeCoopMode", EventManager.get(MenuChangeEvent).recycle(curCoopMode, FlxMath.wrap(curCoopMode + change, 0, bothEnabled ? 3 : 1), change));

		if (event.cancelled) return;


		curCoopMode = event.value;

		if (bothEnabled) {
			coopText.text = coopLabels[curCoopMode];
		} else {
			coopText.text = coopLabels[curCoopMode * (songs[curSelected].coopAllowed ? 2 : 1)];
		}
	}

	/**
	 * Change the current selection.
	 * @param change How much to change
	 * @param force Force the change, even if `change` is equal to 0.
	 */
	public function changeSelection(change:Int = 0, force:Bool = false)
	{
		if (change == 0 && !force) return;

		var bothEnabled = songs[curSelected].coopAllowed && songs[curSelected].opponentModeAllowed;
		var event = event("onChangeSelection", EventManager.get(MenuChangeEvent).recycle(curSelected, FlxMath.wrap(curSelected + change, 0, songs.length-1), change));
		if (event.cancelled) return;

		curSelected = event.value;
        if (event.playMenuSFX) CoolUtil.playMenuSFX(SCROLL, 0.7);

		changeDiff(0, true);

		#if PRELOAD_ALL
			autoplayElapsed = 0;
			songInstPlaying = false;
		#end

		coopText.visible = songs[curSelected].coopAllowed || songs[curSelected].opponentModeAllowed;
	}

	function updateOptionsAlpha() {
		var bullShit:Int = 0;

		for (i in 0...iconArray.length)
			iconArray[i].alpha = lerp(iconArray[i].alpha, #if PRELOAD_ALL songInstPlaying ? 0.45 : #end 0.6, 0.25);

		iconArray[curSelected].alpha = 1;

		for (item in grpSongs.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = lerp(item.alpha, #if PRELOAD_ALL songInstPlaying ? 0.45 : #end 0.6, 0.25);

			if (item.targetY == 0)
				item.alpha = 1;
		}
	}
}

class FreeplaySonglist {
    public var addOGSongs:Bool = false;
    public var songs:Array<SongMetadata> = [];

    public function new() {

    }

    private function _addJSONSongs(songs:Array<FreeplaySong>, source:Bool = false) {
        if (songs != null && songs is Array) {
            for(e in songs) {
                if (e is Dynamic) {
                    if (e.name == null) continue;
                    if (e.icon == null) e.icon = "bf";
                    if (e.color == null) e.color = FreeplayState.defaultColor;
                    if (e.coopAllowed == null) e.coopAllowed = false;
                    if (e.opponentModeAllowed == null) e.opponentModeAllowed = false;

					var meta = new SongMetadata(e.name,
                        e.icon.getDefault("bf"),
                        CoolUtil.getColorFromDynamic(e.color).getDefault(FreeplayState.defaultColor), e.difficulties, source);

					meta.coopAllowed = e.coopAllowed;
					meta.opponentModeAllowed = e.opponentModeAllowed;
                    this.songs.push(meta);
                }
            }
        }
    }

	private function getSongsFromSource(source:funkin.system.AssetsLibraryList.AssetSource) {
		var path:String = Paths.json('freeplaySonglist');
		var addOGSongs:Bool = true;
		if (Paths.assetsTree.existsSpecific(path, "TEXT", source)) {
			try {
				var json:FreeplayJSON = Json.parse(Paths.assetsTree.getSpecificAsset(path, "TEXT", source));
				addOGSongs = CoolUtil.getDefault(json.addOGSongs, true);
				_addJSONSongs(json.songs, source == SOURCE);
			} catch(e) {
				Logs.trace('Couldn\'t parse Freeplay JSON: ${e.toString()}');
			}
		} else {
			var found:Array<FreeplaySong> = [];
			for(s in Paths.getFolderDirectories('songs', false, source)) {
				var sMetaPath = Paths.file('songs/${s}/meta.json');
				if (Paths.assetsTree.existsSpecific(sMetaPath, "TEXT", source)) {
					try {
						var meta:FreeplaySong = Json.parse(Paths.assetsTree.getSpecificAsset(sMetaPath, "TEXT", source));
						if (meta.name == null)
							meta.name = s;
						found.push(meta);
					} catch(e) {
						Logs.trace('Couldn\'t parse metadata for song ${s}: ${e.toString()}');
						found.push({
							name: s
						});
					}
				} else {
					found.push({
						name: s
					});
				}
			}
			_addJSONSongs(found, source == SOURCE);
		}
		return addOGSongs;
	}

    public static function get() {
        var songList = new FreeplaySonglist();

		if (songList.getSongsFromSource(MODS))
			songList.getSongsFromSource(SOURCE);

        return songList;
    }
}

typedef FreeplayJSON = {
    public var addOGSongs:Null<Bool>;
    public var songs:Array<FreeplaySong>;
}

typedef FreeplaySong = {
    public var name:String;
    public var ?icon:String;
    public var ?color:Dynamic;
	public var ?difficulties:Array<String>;
	public var ?coopAllowed:Bool;
	public var ?opponentModeAllowed:Bool;
}

class SongMetadata
{
	public var songName:String = "";
	public var color:FlxColor = FreeplayState.defaultColor;
	public var songCharacter:String = "";
	public var difficulties:Array<String> = ["EASY", "NORMAL", "HARD"];
	public var coopAllowed:Bool = false;
	public var opponentModeAllowed:Bool = false;

	public function new(song:String, songCharacter:String, color:FlxColor, ?difficulties:Array<String>, fromSource:Bool = false)
	{
		this.songName = song;
		this.color = color;
		this.songCharacter = songCharacter;
		if (difficulties != null && difficulties.length > 0) {
			this.difficulties = difficulties;
		} else {
			this.difficulties = difficulties = [for(f in Paths.getFolderContent('songs/${song.toLowerCase()}/charts/', false, fromSource)) if (Path.extension(f = f.toUpperCase()) == "JSON") Path.withoutExtension(f)];
			if (difficulties.length == 3) {
				var hasHard = false, hasNormal = false, hasEasy = false;
				for(d in difficulties) {
					switch(d) {
						case "EASY":	hasEasy = true;
						case "NORMAL":	hasNormal = true;
						case "HARD":	hasHard = true;
					}
				}
				if (hasHard && hasNormal && hasEasy) {
					difficulties[0] = "EASY";
					difficulties[1] = "NORMAL";
					difficulties[2] = "HARD";
				}
			}
		}
		if (this.difficulties.length <= 0)
			this.difficulties.push("NORMAL");
	}
}
