package funkin.menus;

import flixel.FlxG;
import flixel.util.FlxColor;
import funkin.ui.FunkinText;
import haxe.xml.Access;
import flixel.FlxSprite;
import flixel.text.FlxText;

class StoryMenuState extends MusicBeatState {
    public var weekData:Array<WeekData> = [];

    public var characters:Map<String, MenuCharacter> = [];

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
        loadXML();
        
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

    public function loadXML() {
        
    }
}

typedef WeekData = {
    
}

class MenuCharacter extends FlxSprite {
    public function new(xml:Access) {
        super();
    }
}