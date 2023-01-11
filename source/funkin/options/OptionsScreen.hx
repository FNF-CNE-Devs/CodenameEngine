package funkin.options;

import flixel.addons.display.FlxBackdrop;
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

    public var descDrop:FlxBackdrop;
    public var descBG:FlxSprite;
    public var descText:FunkinText;

    public var curSelected:Int = -1;

    public var options:Array<OptionType> = [];

    private var descLetters:Float = 0;

    public var descSpeed:Float = 35;

    public function new() {
        super();
        instance = this;
    }

    public override function create() {
        FlxTransitionableState.skipNextTransIn = true;
        super.create();
        
        bg = new FlxSprite(-80).loadAnimatedGraphic(Paths.image('menus/menuBG'));
        bg.scrollFactor.set();
        bg.scale.set(1.15, 1.15);
        bg.updateHitbox();
        bg.screenCenter();
        bg.antialiasing = true;
        add(bg);

        descText = new FunkinText(0, 0);
        descText.alignment = CENTER;
        descText.scrollFactor.set();
        descText.y = FlxG.height - 50 - descText.height;

        descBG = new FlxSprite(-1, 0).makeGraphic(1, 1, 0xFF000000);
        descBG.scrollFactor.set();
        add(descBG);
        
        descDrop = new FlxBackdrop(null, 1, 0, true, false, 0, 0);
        descDrop.scrollFactor.set();
        add(descDrop);

        descText.antialiasing = descDrop.antialiasing = true;

        for(k=>option in options) {
            option.setPosition(k * 20, 10 + (k * optionHeight));
            add(option);
        }
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

        descBG.alpha = (descDrop.alpha = lerp(descDrop.alpha, 1, 0.25)) * 0.75;
        descDrop.x -= elapsed * 200;
    }

    public function exit() {
        
        FlxTransitionableState.skipNextTransOut = true;
        FlxTransitionableState.skipNextTransIn = true;
        FlxG.switchState(new OptionsMenu());
    }

    public function changeSelection(change:Int) {
        if (change == 0 && curSelected != -1) return;
        CoolUtil.playMenuSFX(0, 0.7);
        if (curSelected != (curSelected = FlxMath.wrap(curSelected + change, 0, options.length - 1))) {
            for(e in options)
                e.selected = false;
            options[curSelected].selected = true;
            scrollDest.set(-50, -(FlxG.height / 2) + ((curSelected + 0.5) * optionHeight));
            updateDesc();
        }
    }

    public function updateDesc() {
        updateDescText(options[curSelected].desc);
    }

    public function updateDescText(text:String) {
        descText.text = '/    ${text}    /';
        @:privateAccess descText.regenGraphic(); //updates the thing

        descDrop.loadFrame(descText.frame);
        descDrop.y = Std.int(FlxG.height - 10 - descText.height);

        descBG.setGraphicSize(FlxG.width + 2, Std.int(descText.height + 20) + 1);
        descBG.updateHitbox();

        descBG.alpha = descDrop.alpha = 0;
        descBG.y = FlxG.height - descBG.height + 1;
    }

    public override function destroy() {
        super.destroy();
        instance = null;
        scrollDest.put();
    }
}