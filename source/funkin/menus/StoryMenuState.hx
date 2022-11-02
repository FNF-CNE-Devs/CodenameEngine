package funkin.menus;

import openfl.utils.Assets;
import flixel.FlxG;
import flixel.util.FlxColor;
import funkin.ui.FunkinText;
import haxe.xml.Access;
import flixel.FlxSprite;
import flixel.text.FlxText;

class StoryMenuState extends MusicBeatState {
    public var weekData:Array<WeekData> = [];

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

    public override function create() {
        super.create();
        loadXMLs();
        
        persistentUpdate = persistentDraw = true;

		scoreText = new FunkinText(10, 10, 0, "SCORE: -", 36);
		scoreText.setFormat(Paths.font("vcr.ttf"), 32);

		weekTitle = new FlxText(10, 10, FlxG.width - 20, "", 32);
		weekTitle.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, RIGHT);
		weekTitle.alpha = 0.7;

        weekBG = new FlxSprite(0, 56).makeGraphic(1, 1, 0xFFFFFFFF);
        weekBG.color = 0xFFF9CF51;
        weekBG.setGraphicSize(FlxG.width, 400);
        weekBG.updateHitbox();

        for(e in [scoreText, weekTitle, weekBG])
            add(e);
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
                                songs: []
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
            trace(weeks);
        } catch(e) {

        }
    }
}

typedef WeekData = {
    var name:String;
    var sprite:String;
    var chars:Array<String>;
    var songs:Array<WeekSong>;
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