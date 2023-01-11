package funkin.options;

import flixel.util.typeLimit.OneOfTwo;
import flixel.FlxState;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup.FlxTypedGroup;
import funkin.ui.Alphabet;
import flixel.math.FlxMath;
import flixel.FlxSprite;
import flixel.FlxG;
import flixel.effects.FlxFlicker;
import funkin.menus.MainMenuState;

import funkin.options.categories.*;

typedef OptionCategory = {
    var name:String;
    var desc:String;
    var state:OneOfTwo<Class<FlxState>, FlxState>;
}
class OptionsMenu extends MusicBeatState {
    public static var fromPlayState:Bool = false;
    public var options:Array<OptionCategory> = [
        {
            name: 'Controls',
            desc: 'Change Controls for Player 1 and Player 2!',
            state: funkin.options.keybinds.KeybindsOptions
        },
        {
            name: 'Gameplay',
            desc: 'Change Gameplay options such as Downscroll, Scroll Speed, Naughtyness...',
            state: GameplayOptions
        },
        {
            name: 'Behaviour',
            desc: 'Change Behaviour options such as Flashing menus...',
            state: BehaviourOptions
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

    public var curSelected:Int = -1;
    public var canSelect:Bool = true;
    public var alphabets:FlxTypedGroup<Alphabet>;

    public function new(?fromPlayState:Bool) {
        super();
        if (fromPlayState != null) OptionsMenu.fromPlayState = fromPlayState;
    }
    public override function create() {
		var bg:FlxSprite = new FlxSprite(-80).loadAnimatedGraphic(Paths.image('menus/menuBGBlue'));
        bg.scrollFactor.set();
		bg.scale.set(1.15, 1.15);
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = true;
		add(bg);

        super.create();
        alphabets = new FlxTypedGroup<Alphabet>();
        for(k=>e in options) {
            var alphabet = new Alphabet(0, (k+1) * (100), e.name, true, false);
            alphabet.screenCenter(X);
            alphabets.add(alphabet);
        }
        add(alphabets);
        changeSelection(1);

        CoolUtil.playMenuSong();
    }

    public override function update(elapsed:Float) {
        super.update(elapsed);
        if (!canSelect) return;
        changeSelection((controls.UP_P ? -1 : 0) + (controls.DOWN_P ? 1 : 0));
        if (controls.ACCEPT && alphabets.members[curSelected] != null) {
            CoolUtil.playMenuSFX(1);
            canSelect = false;
            FlxFlicker.flicker(alphabets.members[curSelected], 1, Options.flashingMenu ? 0.06 : 0.15, false, false, function(flick:FlxFlicker)
            {
                FlxTransitionableState.skipNextTransOut = true;
                if (options[curSelected].state is FlxState)
                    FlxG.switchState(options[curSelected].state);
                else 
                    FlxG.switchState(Type.createInstance(options[curSelected].state, []));
            });
        } else if (controls.BACK) {
            if (fromPlayState)
                FlxG.switchState(new PlayState());
            else
                FlxG.switchState(new MainMenuState());
        }
    }
    
    public function changeSelection(change:Int) {
        if (change == 0) return;
        CoolUtil.playMenuSFX(0, 0.7);
        curSelected = FlxMath.wrap(curSelected + change, 0, options.length-1);
        alphabets.forEach(function(e) {
            e.alpha = 0.6;
        });
        if (alphabets.members[curSelected] != null) alphabets.members[curSelected].alpha = 1;
    }
}