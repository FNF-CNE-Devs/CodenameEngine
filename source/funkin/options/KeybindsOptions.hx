package funkin.options;

import flixel.effects.FlxFlicker;
import funkin.system.Controls;
import funkin.options.Options;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup.FlxTypedGroup;
import funkin.ui.Alphabet;
import flixel.util.FlxColor;
import flixel.input.keyboard.FlxKey;
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
    public var canSelect:Bool = true;
    public var alphabets:FlxTypedGroup<KeybindSetting>;
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

        alphabets = new FlxTypedGroup<KeybindSetting>();
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
                var sparrowIcon:String = null;
                var sparrowAnim:String = null;
                if (e.name.startsWith('{note')) {// is actually a note!!
                    sparrowIcon = "NOTE_assets";
                    sparrowAnim = switch(e.name) {
                        case '{noteLeft}':
                            "purple0";
                        case '{noteDown}':
                            "blue0";
                        case '{noteUp}':
                            "green0";
                        default:
                            "red0";
                    };
                    e.name = e.name.substring(5, e.name.length - 1);
                }
                        
                var text = new KeybindSetting(100, k * 75, e.name, e.control, sparrowIcon, sparrowAnim);
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

            
        super.update(elapsed);
        if (canSelect) {
            changeSelection((controls.UP_P ? -1 : 0) + (controls.DOWN_P ? 1 : 0));
            if (controls.BACK) {
                FlxTransitionableState.skipNextTransIn = true;
                FlxTransitionableState.skipNextTransOut = true;
                FlxG.switchState(new OptionsMenu());
                controls.setKeyboardScheme(Solo);
                return;
            }

            if (controls.ACCEPT) {
                if (alphabets.members[curSelected] != null) {
                    canSelect = false;
                    CoolUtil.playMenuSFX(1);
                    FlxFlicker.flicker(alphabets.members[curSelected], 0.4, 0.1, true, false, function(t) {
                        alphabets.members[curSelected].changeKeybind(false);
                    });
                }
            }
        } else {
            if (alphabets.members[curSelected].changingKeybind < 0)
                canSelect = true;
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
                camFollow.setPosition(FlxG.width / 2, FlxMath.bound(alphabet.y + (alphabet.height / 2) - (35), minH, maxH));
            else
                camFollow.setPosition(FlxG.width / 2, FlxG.height / 2);
        }
    }
}

class KeybindSetting extends FlxTypedSpriteGroup<FlxSprite> {
    public var title:Alphabet;
    public var bind1:Alphabet;
    public var bind2:Alphabet;
    public var icon:FlxSprite;

    public var changingKeybind:Int = -1;
    public var value:String;

    public var option1:Null<FlxKey>;
    public var option2:Null<FlxKey>;
    public function new(x:Float, y:Float, name:String, value:String, ?sparrowIcon:String, ?sparrowAnim:String) {
        super();
        this.value = value;
        title = new Alphabet(0, 0, name, true);
        title.setPosition(100, 0);
        add(title);


        var controlArrayP1:Array<FlxKey> = Reflect.field(Options, 'P1_${value}');
        var controlArrayP2:Array<FlxKey> = Reflect.field(Options, 'P2_${value}');

        option1 = controlArrayP1[0];
        option2 = controlArrayP2[0];

        for(i in 1...3) {
            var b = null;
            if (i == 1)
                b = bind1 = new Alphabet(0, 0, "", false);
            else
                b = bind2 = new Alphabet(0, 0, "", false);

            b.setPosition(FlxG.width * (0.25 * (i+1)) - x, -60);
            add(b);
        }
        updateText();

        if (sparrowIcon != null) {
            icon = new FlxSprite();
            icon.frames = Paths.getSparrowAtlas(sparrowIcon);
            icon.antialiasing = true;
            icon.animation.addByPrefix('icon', sparrowAnim, 24, true);
            icon.animation.play('icon');
            icon.setGraphicSize(75, 75);
            icon.updateHitbox();
            var min = Math.min(icon.scale.x, icon.scale.y);
            icon.scale.set(min, min);
            add(icon);
        }
        
        setPosition(x, y);
    }

    public override function update(elapsed:Float) {
        super.update(elapsed);
        if (changingKeybind >= 0) {
            var key:FlxKey = FlxG.keys.firstJustReleased();
            if (cast(key, Int) <= 0) return;
            if (key == ESCAPE && !FlxG.keys.pressed.SHIFT) {
                changingKeybind = -1;
                return;
            }
            if (changingKeybind == 0) {
                option1 = key;
                Reflect.setField(Options, 'P1_$value', [option1]);
            } else {
                option2 = key;
                Reflect.setField(Options, 'P2_$value', [option2]);
            }
            changingKeybind = -1;
            updateText();
            return;
        }
    }

    public function changeKeybind(p2:Bool = false) {
        FlxG.state.persistentDraw = true;
        FlxG.state.persistentUpdate = true;
        
        changingKeybind = p2 ? 1 : 0;
    }

    public function updateText() {
        bind1.text = '${CoolUtil.keyToString(option1)}';
        bind2.text = '${CoolUtil.keyToString(option2)}';
    }
}