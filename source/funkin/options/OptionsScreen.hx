package funkin.options;

import flixel.util.FlxColor;
import flixel.FlxSprite;
import flixel.FlxG;
/**
 * Direct replica from Week 7 lol
 */
class OptionsScreen extends MusicBeatState {
    public static inline var defaultBGColor:FlxColor = 0xFFFDE871;

    public var bgColor:FlxColor = 0xFFFDE871;
    public var bg:FlxSprite;

    public override function create() {
        super.create();
        
        bg = new FlxSprite(-80).loadGraphic(Paths.image('menus/menuBG'));
        bg.scrollFactor.set();
        bg.scale.set(1.15, 1.15);
        bg.updateHitbox();
        bg.screenCenter();
        bg.antialiasing = true;
        add(bg);
    }
}