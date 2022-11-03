package funkin.menus;

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

    public var lerpScore:Float = 0;
    public var intendedScore:Int = 0;

    public var canSelect:Bool = true;

    public override function create() {
        super.create();
        loadXMLs();
        
        persistentUpdate = persistentDraw = true;

        // WEEK INFO
		scoreText = new FunkinText(10, 10, 0, "SCORE: -", 36);
		scoreText.setFormat(Paths.font("vcr.ttf"), 32);

		weekTitle = new FlxText(10, 10, FlxG.width - 20, "", 32);
		weekTitle.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, RIGHT);
		weekTitle.alpha = 0.7;

        weekBG = new FlxSprite(0, 56).makeGraphic(1, 1, 0xFFFFFFFF);
        weekBG.color = 0xFFF9CF51;
        weekBG.setGraphicSize(FlxG.width, 400);
        weekBG.updateHitbox();


        // DUMBASS ARROWS
		var assets = Paths.getSparrowAtlas('menus/storymenu/assets');
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

        tracklist = new FunkinText(64, weekBG.y + weekBG.height + 44, Std.int(((FlxG.width - 400) / 2) - 128), "TRACKS", 32);
        tracklist.alignment = CENTER;
        tracklist.color = 0xFFE55777;

        for(e in [scoreText, weekTitle, weekBG, tracklist])
            add(e);

        for(week in weeks) {
            for(e in week.difficulties) {
                var le = e.toLowerCase();
                if (difficultySprites[le] == null) {
                    var diffSprite = new FlxSprite(leftArrow.x + leftArrow.width, leftArrow.y);
                    diffSprite.loadAnimatedGraphic(Paths.image('menus/storymenu/difficulties/${le}'));
                    diffSprite.setUnstretchedGraphicSize(Std.int(rightArrow.x - leftArrow.x - leftArrow.width), Std.int(leftArrow.height), false, 1);
                    diffSprite.antialiasing = true;
                    add(diffSprite);

                    difficultySprites[le] = diffSprite;
                }
            }
        }
        changeWeek(0, true);
    }

    var __lastDifficultyTween:FlxTween;
    public override function update(elapsed:Float) {
        super.update(elapsed);

        lerpScore = lerp(lerpScore, intendedScore, 0.5);
        scoreText.text = 'WEEK SCORE:${Math.round(lerpScore)}';
        
        if (canSelect) {
            leftArrow.animation.play(controls.LEFT ? 'press' : 'idle');
            rightArrow.animation.play(controls.RIGHT ? 'press' : 'idle');

            if (controls.BACK)
                FlxG.switchState(new MainMenuState());

            
            changeDifficulty((controls.LEFT_P ? -1 : 0) + (controls.RIGHT_P ? 1 : 0));
            changeWeek((controls.UP_P ? -1 : 0) + (controls.DOWN_P ? 1 : 0));

            if (controls.ACCEPT) {
            }
        } else {
            for(e in [leftArrow, rightArrow])
                e.animation.play('idle');
        }
    }

    var __oldDiffName = null;
    public function changeDifficulty(change:Int, force:Bool = false) {
        if (change == 0 && !force) return;

        curDifficulty = FlxMath.wrap(curDifficulty + change, 0, weeks[curWeek].difficulties.length-1);

        if (__oldDiffName != (__oldDiffName = weeks[curWeek].difficulties[curDifficulty].toLowerCase())) {
            for(e in difficultySprites) e.visible = false;

            var diffSprite = difficultySprites[__oldDiffName];
            if (diffSprite != null) {
                diffSprite.visible = true;
                
                if (__lastDifficultyTween != null)
                    __lastDifficultyTween.cancel();
                diffSprite.alpha = 0;
                diffSprite.y = leftArrow.y - 15;

                FlxTween.tween(diffSprite, {y: leftArrow.y + 15, alpha: 1}, 0.07);
            }

            intendedScore = Highscore.getWeekScore(weeks[curWeek].name, weeks[curWeek].difficulties[curDifficulty]).score;
        }
    }

    public function changeWeek(change:Int, force:Bool = false) {
        if (change == 0 && !force) return;

        changeDifficulty(0, true);
    }

    public function loadXMLs() {
        loadXML(Paths.xml('weeks'));
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
                                spritePath: Paths.image(char.getAtt('scale').getDefault('menus/storymenu/characters/${char.att.name}')),
                                scale: Std.parseFloat(char.getAtt('scale')).getDefault(1),
                                xml: char
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
                                    hide: week.getAtt('hide').getDefault('false') == "true"
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
}