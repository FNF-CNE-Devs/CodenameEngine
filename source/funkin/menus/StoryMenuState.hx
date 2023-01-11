package funkin.menus;

import funkin.scripting.events.*;
import flixel.util.FlxTimer;
import flixel.math.FlxPoint;
import flixel.graphics.frames.FlxFramesCollection;
import flixel.group.FlxGroup.FlxTypedGroup;
import funkin.game.Highscore;
import flixel.tweens.FlxTween;
import openfl.utils.Assets;
import flixel.FlxG;
import flixel.math.FlxMath;
import flixel.util.FlxColor;
import funkin.ui.FunkinText;
import haxe.xml.Access;
import flixel.FlxSprite;
import flixel.text.FlxText;

class StoryMenuState extends MusicBeatState {
    public var characters:Map<String, MenuCharacter> = [];
    public var weeks:Array<WeekData> = [];

    public var scoreText:FlxText;
    public var tracklist:FlxText;
    public var weekTitle:FlxText;

    public var curDifficulty:Int = 0;
    public var curWeek:Int = 0;

    public var difficultySprites:Map<String, FlxSprite> = [];
    public var weekBG:FlxSprite;
    public var leftArrow:FlxSprite;
    public var rightArrow:FlxSprite;
    public var blackBar:FlxSprite;

    public var lerpScore:Float = 0;
    public var intendedScore:Int = 0;

    public var canSelect:Bool = true;

    public var weekSprites:FlxTypedGroup<MenuItem>;
    public var characterSprites:FlxTypedGroup<MenuCharacterSprite>;

    public var charFrames:Map<String, FlxFramesCollection> = [];
 
    public override function create() {
        super.create();
        loadXMLs();
        persistentUpdate = persistentDraw = true;
        
        // WEEK INFO
        blackBar = new FlxSprite(0, 0).makeGraphic(1, 1, 0xFFFFFFFF);
        blackBar.color = 0xFF000000;
        blackBar.setGraphicSize(FlxG.width, 56);
        blackBar.updateHitbox();

		scoreText = new FunkinText(10, 10, 0, "SCORE: -", 36);
		scoreText.setFormat(Paths.font("vcr.ttf"), 32);

		weekTitle = new FlxText(10, 10, FlxG.width - 20, "", 32);
		weekTitle.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, RIGHT);
		weekTitle.alpha = 0.7;

        weekBG = new FlxSprite(0, 56).makeGraphic(1, 1, 0xFFFFFFFF);
        weekBG.color = 0xFFF9CF51;
        weekBG.setGraphicSize(FlxG.width, 400);
        weekBG.updateHitbox();

        weekSprites = new FlxTypedGroup<MenuItem>();

        // DUMBASS ARROWS
		var assets = Paths.getFrames('menus/storymenu/assets');
        var directions = ["left", "right"];

        leftArrow = new FlxSprite((FlxG.width + 400) / 2, weekBG.y + weekBG.height + 10 + 10);
        rightArrow = new FlxSprite(FlxG.width - 10, weekBG.y + weekBG.height + 10 + 10);
        for(k=>arrow in [leftArrow, rightArrow]) {
            var dir = directions[k];

            arrow.frames = assets;
            arrow.animation.addByPrefix('idle', 'arrow $dir');
            arrow.animation.addByPrefix('press', 'arrow push $dir', 24, false);
            arrow.animation.play('idle');
            add(arrow);
        }
        rightArrow.x -= rightArrow.width;

        tracklist = new FunkinText(16, weekBG.y + weekBG.height + 44, Std.int(((FlxG.width - 400) / 2) - 80), "TRACKS", 32);
        tracklist.alignment = CENTER;
        tracklist.color = 0xFFE55777;

        add(weekSprites);
        for(e in [blackBar, scoreText, weekTitle, weekBG, tracklist]) {
            e.scrollFactor.set();
            add(e);
        }

        characterSprites = new FlxTypedGroup<MenuCharacterSprite>();
        for(i in 0...3) {
            characterSprites.add(new MenuCharacterSprite(i));
        }
        add(characterSprites);

        for(i=>week in weeks) {
            var spr:MenuItem = new MenuItem(0, (i * 120) + 480, 'menus/storymenu/weeks/${week.sprite}');
            weekSprites.add(spr);

            for(e in week.difficulties) {
                var le = e.toLowerCase();
                if (difficultySprites[le] == null) {
                    var diffSprite = new FlxSprite(leftArrow.x + leftArrow.width, leftArrow.y);
                    diffSprite.loadAnimatedGraphic(Paths.image('menus/storymenu/difficulties/${le}'));
                    diffSprite.setUnstretchedGraphicSize(Std.int(rightArrow.x - leftArrow.x - leftArrow.width), Std.int(leftArrow.height), false, 1);
                    diffSprite.antialiasing = true;
                    diffSprite.scrollFactor.set();
                    add(diffSprite);

                    difficultySprites[le] = diffSprite;
                }
            }
        }

        changeWeek(0, true);
        
		DiscordUtil.changePresence("In the Menus", null);
    }

    var __lastDifficultyTween:FlxTween;
    public override function update(elapsed:Float) {
        super.update(elapsed);

        lerpScore = lerp(lerpScore, intendedScore, 0.5);
        scoreText.text = 'WEEK SCORE:${Math.round(lerpScore)}';
        
        if (canSelect) {
            if (leftArrow != null && leftArrow.exists) leftArrow.animation.play(controls.LEFT ? 'press' : 'idle');
            if (rightArrow != null && rightArrow.exists) rightArrow.animation.play(controls.RIGHT ? 'press' : 'idle');

            if (controls.BACK) {
                goBack();
            }

            
            changeDifficulty((controls.LEFT_P ? -1 : 0) + (controls.RIGHT_P ? 1 : 0));
            changeWeek((controls.UP_P ? -1 : 0) + (controls.DOWN_P ? 1 : 0));

            if (controls.ACCEPT)
                selectWeek();
        } else {
            for(e in [leftArrow, rightArrow])
                if (e != null && e.exists)
                    e.animation.play('idle');
        }
    }

    public function goBack() {
        var event = event("onGoBack", new CancellableEvent());
        if (!event.cancelled)
            FlxG.switchState(new MainMenuState());
    }

    public function changeWeek(change:Int, force:Bool = false) {
        if (change == 0 && !force) return;

        var event = event("onChangeWeek", EventManager.get(MenuChangeEvent).recycle(curWeek, FlxMath.wrap(curWeek + change, 0, weeks.length-1), change));
        if (event.cancelled) return;
        curWeek = event.value;
        
        if (!force) CoolUtil.playMenuSFX();
        for(k=>e in weekSprites.members) {
            e.targetY = k - curWeek;
        }
        tracklist.text = 'TRACKS\n\n${[for(e in weeks[curWeek].songs) if (!e.hide) e.name.toUpperCase()].join('\n')}';

        for(i in 0...3)
            characterSprites.members[i].changeCharacter(characters[weeks[curWeek].chars[i]]);

        changeDifficulty(0, true);
    }

    var __oldDiffName = null;
    public function changeDifficulty(change:Int, force:Bool = false) {
        if (change == 0 && !force) return;

        var event = event("onChangeDifficulty", EventManager.get(MenuChangeEvent).recycle(curDifficulty, FlxMath.wrap(curDifficulty + change, 0, weeks[curWeek].difficulties.length-1), change));
        if (event.cancelled) return;
        curDifficulty = event.value;

        if (__oldDiffName != (__oldDiffName = weeks[curWeek].difficulties[curDifficulty].toLowerCase())) {
            for(e in difficultySprites) e.visible = false;

            var diffSprite = difficultySprites[__oldDiffName];
            if (diffSprite != null) {
                diffSprite.visible = true;
                
                if (__lastDifficultyTween != null)
                    __lastDifficultyTween.cancel();
                diffSprite.alpha = 0;
                diffSprite.y = leftArrow.y - 15;

                FlxTween.tween(diffSprite, {y: leftArrow.y, alpha: 1}, 0.07);
            }
        }
        
        intendedScore = Highscore.getWeekScore(weeks[curWeek].name, weeks[curWeek].difficulties[curDifficulty]).score;
    }

    public function loadXMLs() {
        loadXML(Paths.xml('weeks'));
    }

    public override function destroy() {
        super.destroy();
        for(e in characters)
            if (e != null && e.offset != null)
                e.offset.put();
    }

    public function selectWeek() {
        

        var event = event("onWeekSelect", EventManager.get(WeekSelectEvent).recycle(weeks[curWeek], weeks[curWeek].difficulties[curDifficulty], curWeek, curDifficulty));
        if (event.cancelled) return;

        canSelect = false;
        CoolUtil.playMenuSFX(1);

        for(char in characterSprites)
            if (char.animation.exists("confirm"))
                char.animation.play("confirm");

        CoolUtil.loadWeek(weeks[curWeek], weeks[curWeek].difficulties[curDifficulty]);


        new FlxTimer().start(1, function(tmr:FlxTimer)
        {
            FlxG.switchState(new PlayState());
        });
        weekSprites.members[curWeek].startFlashing();
    }

    public function loadXML(xmlPath:String) {
        try {
            var xml = new Access(Xml.parse(Assets.getText(xmlPath)).firstElement());

            for(el in xml.elements) {
                switch(el.name) {
                    case 'characters':
                        for(k=>char in el.nodes.char) {
                            if (!char.has.name) {
                                Logs.trace('weeks.xml: Character at index ${k} has no name. Skipping...', WARNING);
                                continue;
                            }
                            if (characters[char.att.name] != null) continue;
                            var charObj:MenuCharacter = {
                                spritePath: Paths.image(char.getAtt('sprite').getDefault('menus/storymenu/characters/${char.att.name}')),
                                scale: Std.parseFloat(char.getAtt('scale')).getDefault(1),
                                xml: char,
                                offset: FlxPoint.get(
                                    Std.parseFloat(char.getAtt('x')).getDefault(0),
                                    Std.parseFloat(char.getAtt('y')).getDefault(0)
                                )
                            };
                            characters[char.att.name] = charObj;
                        }
                    case 'weeks':
                        for(k=>week in el.nodes.week) {
                            if (!week.has.name) {
                                Logs.trace('weeks.xml: Week at index ${k} has no name. Skipping...', WARNING);
                                continue;
                            }
                            var weekObj:WeekData = {
                                name: week.att.name,
                                sprite: week.getAtt('sprite').getDefault('week${k}'),
                                chars: [null, null, null],
                                songs: [],
                                difficulties: ['easy', 'normal', 'hard']
                            };

                            var diffNodes = week.nodes.difficulty;
                            if (diffNodes.length > 0) {
                                var diffs:Array<String> = [];
                                for(e in diffNodes) {
                                    if (e.has.name) diffs.push(e.att.name);
                                }
                                if (diffs.length > 0)
                                    weekObj.difficulties = diffs;
                            }

                            if (week.has.chars) {
                                for(k=>e in week.att.chars.split(",")) {
                                    if (e.trim() == "" || e == "none" || e == "null")
                                        weekObj.chars[k] = null;
                                    else
                                        weekObj.chars[k] = e.trim();
                                }
                            }
                            for(k2=>song in week.nodes.song) {
                                if (!song.has.name) {
                                    Logs.trace('weeks.xml: Song at index ${k2} in week ${weekObj.name} has no name. Skipping...', WARNING);
                                    continue;
                                }
                                weekObj.songs.push({
                                    name: song.att.name,
                                    hide: song.getAtt('hide').getDefault('false') == "true"
                                });
                            }
                            if (weekObj.songs.length <= 0) {
                                Logs.trace('weeks.xml: Week ${weekObj.name} has no songs. Skipping...', WARNING);
                                continue;
                            }
                            weeks.push(weekObj);
                        }
                }
            }
        } catch(e) {
            Logs.trace('Failed to parse data/weeks.xml: $e', ERROR);
        }
    }
}

typedef WeekData = {
    var name:String;
    var sprite:String;
    var chars:Array<String>;
    var songs:Array<WeekSong>;
    var difficulties:Array<String>;
}

typedef WeekSong = {
    var name:String;
    var hide:Bool;
}

typedef MenuCharacter = {
    var spritePath:String;
    var xml:Access;
    var scale:Float;
    var offset:FlxPoint;
    // var frames:FlxFramesCollection;
}

class MenuCharacterSprite extends FlxSprite
{
    public var character:String;

    var pos:Int;

    public function new(pos:Int) {
        super(0, 70);
        this.pos = pos;
        visible = false;
        antialiasing = true;
    }

    public var oldChar:MenuCharacter = null;

    public function changeCharacter(data:MenuCharacter) {
        visible = (data != null);
        if (!visible)
            return;

        if (oldChar != (oldChar = data)) {
            CoolUtil.loadAnimatedGraphic(this, data.spritePath);
            for(e in data.xml.nodes.anim) {
                if (e.getAtt("name") == "idle")
                    animation.remove("idle");
    
                XMLUtil.addXMLAnimation(this, e);
            }
            animation.play("idle");
            scale.set(data.scale, data.scale);
            updateHitbox();
            offset.x += data.offset.x;
            offset.y += data.offset.y;
    
            x = (FlxG.width * 0.25) * (1 + pos) - 150;
        }
    }
}
class MenuItem extends FlxSprite
{
	public var targetY:Float = 0;

	public function new(x:Float, y:Float, path:String)
	{
		super(x, y);
		CoolUtil.loadAnimatedGraphic(this, Paths.image(path, null, true));
        screenCenter(X);
        antialiasing = true;
	}

	private var isFlashing:Bool = false;

	public function startFlashing():Void
	{
		isFlashing = true;
	}

	// if it runs at 60fps, fake framerate will be 6
	// if it runs at 144 fps, fake framerate will be like 14, and will update the graphic every 0.016666 * 3 seconds still???
	// so it runs basically every so many seconds, not dependant on framerate??
	// I'm still learning how math works thanks whoever is reading this lol
	// var fakeFramerate:Int = Math.round((1 / FlxG.elapsed) / 10);

    // hi ninja muffin
    // i have found a more efficient way
    // dw, judging by how week 7 looked you prob know how to do maths
    // goodbye
    var time:Float = 0;

	override function update(elapsed:Float)
	{
		super.update(elapsed);
        time += elapsed;
		y = CoolUtil.fpsLerp(y, (targetY * 120) + 480, 0.17);

        if (isFlashing)
            color = (time % 0.1 > 0.05) ? FlxColor.WHITE : 0xFF33ffff;
	}
}
