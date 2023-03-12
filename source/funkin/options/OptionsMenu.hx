package funkin.options;

import flixel.tweens.FlxTween;
import funkin.options.OptionsScreen;
import funkin.menus.MainMenuState;
import funkin.options.type.TextOption;
import flixel.util.typeLimit.OneOfTwo;
import funkin.options.type.OptionType;
import funkin.options.categories.*;

class OptionsMenu extends MusicBeatState {
    
    public static var mainOptions:Array<OptionCategory> = [
        {
            name: 'Controls',
            desc: 'Change Controls for Player 1 and Player 2!',
            state: null,
            substate: funkin.options.keybinds.KeybindsOptions
        },
        {
            name: 'Gameplay',
            desc: 'Change Gameplay options such as Downscroll, Scroll Speed, Naughtyness...',
            state: GameplayOptions
        },
        {
            name: 'Appearance',
            desc: 'Change Appearance options such as Flashing menus...',
            state: AppearanceOptions
        },
        {
            name: 'Miscellaneous',
            desc: 'Use this menu to reset save data or engine settings.',
            state: MiscOptions
        },
        {
            name: 'Debug Options',
            desc: 'Use this menu to change debug options.',
            state: DebugOptions
        }
    ];
    
    public var options:Array<OptionTypeDef>;
    public var optionsTree:OptionsTree;
    public function new(?options:Array<OptionTypeDef>) {
        super();
    }

    public override function create() {
        super.create();

        var optionSprites:Array<OptionType> = [];
        if (options == null) {
            optionSprites = [for(o in mainOptions) new TextOption(o.name, o.desc, function() {
                if (o.substate != null) {
                    persistentUpdate = false;
                    persistentDraw = true;
                    if (o.substate is MusicBeatSubstate) {
                        openSubState(o.substate);
                    } else {
                        openSubState(Type.createInstance(o.substate, []));
                    }
                } else {
                    if (o.state is OptionsScreen) {
                        optionsTree.add(o.state);
                    } else {
                        optionsTree.add(Type.createInstance(o.state, []));
                    }
                }
            })];
        } else {
            optionSprites = [for(o in options) Type.createInstance(o.type, o.args)];
        }

        var bg:FlxSprite = new FlxSprite(-80).loadAnimatedGraphic(Paths.image('menus/menuBGBlue'));
        // bg.scrollFactor.set();
		bg.scale.set(1.15, 1.15);
		bg.updateHitbox();
		bg.screenCenter();
        bg.scrollFactor.set();
		bg.antialiasing = true;
		add(bg);

        optionsTree = new OptionsTree();
        optionsTree.onMenuChange = onMenuChange;
        optionsTree.onMenuClose = onMenuClose;
        var mainOptionScreen:OptionsScreen = new OptionsScreen();
        for(o in optionSprites)
            mainOptionScreen.add(o);
        optionsTree.add(mainOptionScreen);
        add(optionsTree);

        FlxG.camera.scroll.set(-FlxG.width, 0);
    }

    public function onMenuChange() {
        if (optionsTree.members.length <= 0) {
            exit();
        } else {
            if (menuChangeTween != null) {
                menuChangeTween.cancel();
            }

            menuChangeTween = FlxTween.tween(FlxG.camera.scroll, {x: FlxG.width * Math.max(0, (optionsTree.members.length-1))}, 1.5, {ease: menuTransitionEase, onComplete: function(t) {
                optionsTree.clearLastMenu();
                menuChangeTween = null;
            }});
            // TODO: update top info
        }
    }

    public function exit() {
        Options.save();
        Options.applySettings();
        FlxG.switchState(new MainMenuState());
    }

    public function onMenuClose(m:OptionsScreen) {
        CoolUtil.playMenuSFX(CANCEL);
    }

    var menuChangeTween:FlxTween;
    public override function update(elapsed:Float) {
        super.update(elapsed);
    }

    public static inline function menuTransitionEase(e:Float)
        return FlxEase.quintInOut(FlxEase.cubeOut(e));
}

typedef OptionCategory = {
    var name:String;
    var desc:String;
    var state:OneOfTwo<OptionsScreen, Class<OptionsScreen>>;
    var ?substate:OneOfTwo<MusicBeatSubstate, Class<MusicBeatSubstate>>;
}

typedef OptionTypeDef = {
    var type:Class<OptionType>;
    var args:Array<Dynamic>;
}