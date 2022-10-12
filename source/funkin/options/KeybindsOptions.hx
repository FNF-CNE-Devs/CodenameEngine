package funkin.options;

import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup.FlxTypedGroup;
import funkin.ui.Alphabet;
import flixel.util.FlxColor;
import flixel.math.FlxMath;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxG;

using StringTools;

class KeybindsOptions extends MusicBeatState {
    public var categories = [
        {
            name: 'Notes',
            settings: [
                {
                    name: '{noteLeft}',
                    control: 'LEFT'
                },
                {
                    name: '{noteDown}',
                    control: 'DOWN'
                },
                {
                    name: '{noteUp}',
                    control: 'UP'
                },
                {
                    name: '{noteRight}',
                    control: 'RIGHT'
                },
                {
                    name: 'Reset',
                    control: 'RESET'
                },
                {
                    name: 'Pause',
                    control: 'PAUSE'
                },
            ]
        },
        {
            name: 'UI',
            settings: [
                {
                    name: 'Accept',
                    control: 'ACCEPT'
                },
                {
                    name: 'Back',
                    control: 'BACK'
                }
            ]
        }
    ];

    public var curSelected:Int = -1;
    public var alphabets:FlxTypedGroup<FlxSprite>;
    public var bg:FlxSprite;
    public var coloredBG:FlxSprite;
    public var noteColors:Array<FlxColor> = [
        0xFFC24B99,
        0xFF00FFFF,
        0xFF12FA05,
        0xFFF9393F
    ];
    public var camFollow:FlxObject = new FlxObject(0, 0, 2, 2);

    public override function create() {
        super.create();

        alphabets = new FlxTypedGroup<FlxSprite>();
		bg = new FlxSprite(-80).loadGraphic(Paths.image('menuBGBlue'));
		coloredBG = new FlxSprite(-80).loadGraphic(Paths.image('menuDesat'));
        for(bg in [bg, coloredBG]) {
            bg.scrollFactor.set();
            bg.scale.set(1.15, 1.15);
            bg.updateHitbox();
            bg.screenCenter();
            bg.antialiasing = true;
            add(bg);
        }
        coloredBG.alpha = 0;

        var k:Int = 0;
        for(category in categories) {
            k++;
            var title = new Alphabet(0, k * 75, category.name, true);
            title.screenCenter(X);
            add(title);
            
            k++;
            for(e in category.settings) {
                // TODO!!
                var xOffset:Float = 200;
                if (e.name.startsWith('{note')) {// is actually a note!!
                    var note:FlxSprite = new FlxSprite(100, k * 75);
                    note.frames = Paths.getSparrowAtlas('NOTE_assets');
                    var animName = '${switch(e.name) {
                        case '{noteLeft}':
                            "purple";
                        case '{noteDown}':
                            "blue";
                        case '{noteUp}':
                            "green";
                        default:
                            "red";
                    }}0';
                    e.name = e.name.substring(5, e.name.length - 1);
                    note.antialiasing = true;
                    note.animation.addByPrefix('note', animName, 24, true);
                    note.animation.play('note');
                    note.setGraphicSize(75, 75);
                    note.updateHitbox();
                    var min = Math.min(note.scale.x, note.scale.y);
                    note.scale.set(min, min);
                    add(note);
                }
                        
                var text = new Alphabet(0, k * 75, e.name, true);
                text.x = xOffset;
                alphabets.add(text);
                k++;
            }
        }
        add(alphabets);
        changeSelection(1);

        FlxG.camera.follow(camFollow, LOCKON, 0.125);
        add(camFollow);
    }

    public override function update(elapsed:Float) {
        super.update(elapsed);

        if (curSelected < 4) {
            if (coloredBG.alpha == 0)
                coloredBG.color = noteColors[curSelected];
            else
                coloredBG.color = CoolUtil.lerpColor(coloredBG.color, noteColors[curSelected], 0.0625);

            coloredBG.alpha = lerp(coloredBG.alpha, 1, 0.0625);
        } else
            coloredBG.alpha = lerp(coloredBG.alpha, 0, 0.0625);

        changeSelection((controls.UP_P ? -1 : 0) + (controls.DOWN_P ? 1 : 0));

        if (controls.BACK) {
            FlxTransitionableState.skipNextTransIn = true;
            FlxTransitionableState.skipNextTransOut = true;
            FlxG.switchState(new OptionsMenu());
        }
    }
    
    public function changeSelection(change:Int) {
        if (change == 0) return;
        CoolUtil.playMenuSFX(0, 0.4);
        curSelected = FlxMath.wrap(curSelected + change, 0, alphabets.length-1);
        alphabets.forEach(function(e) {
            e.alpha = 0.6;
        });
        if (alphabets.members[curSelected] != null) {
            var alphabet = alphabets.members[curSelected];
            alphabet.alpha = 1;
            var minH = FlxG.height / 2;
            var maxH = alphabets.members[alphabets.length-1].y + alphabets.members[alphabets.length-1].height - (FlxG.height / 2);
            if (minH < maxH)
                camFollow.setPosition(FlxG.width / 2, FlxMath.bound(alphabet.y + (alphabet.height / 2) + 75, minH, maxH));
            else
                camFollow.setPosition(FlxG.width / 2, FlxG.height / 2);
        }
    }
}

class KeybindSetting extends FlxTypedGroup<FlxSprite> {
    public var title:Alphabet;
    public var bind1:Alphabet;
    public function new(x:Float, y:Float, name:String, value:String, ?sparrowIcon:String, ?sparrowAnim:String) {
        super();
        title = new Alphabet(0, 0, name, true);
        title.setPosition(100, 0);
        add(title);

        for(i in 1...2) {
            var b = null;
            if (i == 1)
                b = bind1 = new Alphabet(0, 0, "", false);
            else
                b = bind2 = new Alphabet(0, 0, "", false);
            b.text = "test";
            b.x = FlxG.width * (0.25 * (i+1));
            add(b);
        }
        setPosition(x, y);
    }
}