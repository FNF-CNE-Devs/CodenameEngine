package funkin.options;

import funkin.ui.FunkinText;
import flixel.text.FlxText;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import flixel.addons.transition.FlxTransitionableState;
import flixel.FlxSprite;
import flixel.FlxG;
import funkin.options.type.OptionType;
/**
 * Direct replica from Week 7 lol
 */
class OptionsScreen extends MusicBeatState {
    public static inline var defaultBGColor:FlxColor = 0xFFFDE871;

    public static var instance:OptionsScreen;
    public static var optionHeight:Float = 120;

    // public var bgColor:FlxColor = 0xFFFDE871;
    public var bg:FlxSprite;

    public var descBG:FlxSprite;
    public var descText:FunkinText;

    public var curSelected:Int = -1;

    public var options:Array<OptionType> = [];

    private var transparentFormat:FlxTextFormat;
    private var descLetters:Float = 0;

    public var descSpeed:Float = 35;

    public function new() {
        super();
        instance = this;
    }

    public override function create() {
        FlxTransitionableState.skipNextTransIn = true;
        super.create();
        
        bg = new FlxSprite(-80).loadGraphic(Paths.image('menus/menuBG'));
        bg.scrollFactor.set();
        bg.scale.set(1.15, 1.15);
        bg.updateHitbox();
        bg.screenCenter();
        bg.antialiasing = true;
        add(bg);

        descText = new FunkinText(10, 10, FlxG.width - 20);
        descText.alignment = CENTER;
        add(descText);

        for(k=>option in options) {
            option.setPosition(k * 20, 10 + (k * optionHeight));
            add(option);
        }

        transparentFormat = new FlxTextFormat(FlxColor.TRANSPARENT);
        changeSelection(1);
    }

    public var scrollDest:FlxPoint = FlxPoint.get(0, 0);
    public override function update(elapsed:Float) {
        super.update(elapsed);
        changeSelection((controls.DOWN_P ? 1 : 0) + (controls.UP_P ? -1 : 0));
        if (controls.ACCEPT) {
            options[curSelected].onSelect();
        }
        if (controls.BACK) {
            Options.applySettings();
            Options.save();
            exit();
        }
        FlxG.camera.scroll.x = lerp(FlxG.camera.scroll.x, scrollDest.x, 0.25);
        FlxG.camera.scroll.y = lerp(FlxG.camera.scroll.y, scrollDest.y, 0.25);

        for(option in options) {
            var angle = Math.cos((option.y + (optionHeight / 2) - (FlxG.camera.scroll.y + (FlxG.height / 2))) / FlxG.height * Math.PI);

            option.x = -50 + (Math.abs(angle) * 150);
        }
    var offset:Int;
        if (Std.int(descLetters) != (offset = Std.int(Math.min(descText.text.length, descLetters += elapsed * descSpeed)))) {
            descText.clearFormats();
            descText.addFormat(transparentFormat, offset, descText.text.length);
        }
    }

    public function exit() {
        
        FlxTransitionableState.skipNextTransOut = true;
        FlxTransitionableState.skipNextTransIn = true;
        FlxG.switchState(new OptionsMenu(false));
    }

    public function changeSelection(change:Int) {
        if (change == 0 && curSelected != -1) return;
        CoolUtil.playMenuSFX(0);
        if (curSelected != (curSelected = FlxMath.wrap(curSelected + change, 0, options.length - 1))) {
            for(e in options)
                e.selected = false;
            options[curSelected].selected = true;
            scrollDest.set(-50, -(FlxG.height / 2) + ((curSelected + 0.5) * optionHeight));
            updateDesc();
        }
    }

    public function updateDesc() {
        descLetters = 0;
        descText.text = options[curSelected].desc;
        descSpeed = descText.text.length;
        descText.addFormat(transparentFormat, 0, descText.text.length);
    }

    public override function destroy() {
        super.destroy();
        instance = null;
    }
}