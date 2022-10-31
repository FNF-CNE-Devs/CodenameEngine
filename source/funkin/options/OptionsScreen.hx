package funkin.options;

import flixel.math.FlxMath;
import flixel.util.FlxColor;
import flixel.FlxSprite;
import flixel.FlxG;
import funkin.options.type.OptionType;
/**
 * Direct replica from Week 7 lol
 */
class OptionsScreen extends MusicBeatState {
    public static inline var defaultBGColor:FlxColor = 0xFFFDE871;

    public static var instance:OptionsScreen;

    // public var bgColor:FlxColor = 0xFFFDE871;
    public var bg:FlxSprite;
    public var curSelected:Int = -1;

    public var options:Array<OptionType> = [];

    public function new() {
        super();
        instance = this;
    }

    public override function create() {
        super.create();
        
        bg = new FlxSprite(-80).loadGraphic(Paths.image('menus/menuBG'));
        bg.scrollFactor.set();
        bg.scale.set(1.15, 1.15);
        bg.updateHitbox();
        bg.screenCenter();
        bg.antialiasing = true;
        add(bg);

        for(k=>option in options) {
            option.setPosition(0, 10 + (k * 120));
            add(option);
        }
        changeSelection(1);
    }

    public override function update(elapsed:Float) {
        super.update(elapsed);
        changeSelection((controls.DOWN_P ? 1 : 0) + (controls.UP_P ? -1 : 0));
        if (controls.ACCEPT) {
            options[curSelected].onSelect();
        }
        if (controls.BACK)
            FlxG.switchState(new OptionsMenu(false));
    }

    public function changeSelection(change:Int) {
        if (change == 0 && curSelected != -1) return;
        curSelected = FlxMath.wrap(curSelected + change, 0, options.length - 1);
        for(e in options)
            e.selected = false;
        options[curSelected].selected = true;
        CoolUtil.playMenuSFX(0);
    }

    public override function destroy() {
        super.destroy();
        instance = null;
    }
}