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

	var songs:Array<SongMetadata> = [];

	var selector:FlxText;
	var curSelected:Int = 0;
	var curDifficulty:Int = 1;

	var scoreText:FlxText;
	var diffText:FlxText;
	var lerpScore:Int = 0;
	var intendedScore:Int = 0;

	var songList:FreeplaySonglist;
	var scoreBG:FlxSprite;

	var bg:FlxSprite;

	private var grpSongs:FlxTypedGroup<Alphabet>;
	private var curPlaying:Bool = false;

	private var iconArray:Array<HealthIcon> = [];

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

		add(scoreText);

		changeSelection(0, true);
		changeDiff();

		super.create();
	}
	

	#if PRELOAD_ALL
	var autoplayElapsed:Float = 0;
	var songInstPlaying:Bool = true;
	var curPlayingInst:String = null;
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

		changeSelection((controls.UP_P ? -1 : 0) + (controls.DOWN_P ? 1 : 0));
		changeDiff((controls.LEFT_P ? -1 : 0) + (controls.RIGHT_P ? 1 : 0));
		// putting it before so that its actually smooth
		updateOptionsAlpha();

		scoreText.text = "PERSONAL BEST:" + lerpScore;
		scoreBG.scale.set(Math.max(diffText.width, scoreText.width) + 8, 66);
		scoreBG.updateHitbox();
		scoreBG.x = FlxG.width - scoreBG.width;

		scoreText.x = scoreBG.x + 4;
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
			CoolUtil.playMenuSFX(2, 0.7);
			FlxG.switchState(new MainMenuState());
		}

		if (controls.ACCEPT && !dontPlaySongThisFrame)
		{
			CoolUtil.loadSong(songs[curSelected].songName, songs[curSelected].difficulties[curDifficulty]);
			FlxG.switchState(new PlayState());
		}
	}

	function changeDiff(change:Int = 0, force:Bool = false)
	{
		if (change == 0 && !force) return;

		var curSong = songs[curSelected];
		curDifficulty = FlxMath.wrap(curDifficulty + change, 0, curSong.difficulties.length-1);

		#if !switch
		intendedScore = Highscore.getScore(curSong.songName, curSong.difficulties[curDifficulty]).score;
		#end

		
		if (curSong.difficulties.length > 1)
			diffText.text = '< ${curSong.difficulties[curDifficulty]} >';
		else
			diffText.text = curSong.difficulties[curDifficulty];
	}

	function changeSelection(change:Int = 0, force:Bool = false)
	{
		if (change == 0 && !force) return;
        CoolUtil.playMenuSFX(0, 0.7);

		curSelected = FlxMath.wrap(curSelected + change, 0, songs.length-1);

		changeDiff(0, true);
		
		#if PRELOAD_ALL
			autoplayElapsed = 0;
			songInstPlaying = false;
		#end
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

                    this.songs.push(new SongMetadata(e.name,
                        e.icon.getDefault("bf"),
                        CoolUtil.getColorFromDynamic(e.color).getDefault(FreeplayState.defaultColor), e.difficulties, source));
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
}

class SongMetadata
{
	public var songName:String = "";
	public var color:FlxColor = FreeplayState.defaultColor;
	public var songCharacter:String = "";
	public var difficulties:Array<String> = ["EASY", "NORMAL", "HARD"];

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
