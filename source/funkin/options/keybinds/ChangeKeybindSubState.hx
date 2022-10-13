package funkin.options.keybinds;

import flixel.FlxCamera;
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

class ChangeKeybindSubState extends MusicBeatSubstate {
    var callback:FlxKey->Void;
    var cancelCallback:Void->Void;
    public override function new(callback:FlxKey->Void, cancelCallback:Void->Void) {
        this.callback = callback;
        this.cancelCallback = cancelCallback;
        super();
    }
    public override function create() {
        super.create();

    }

    public override function update(elapsed:Float) {
        super.update(elapsed);
        var key:FlxKey = FlxG.keys.firstJustReleased();
        if (cast(key, Int) <= 0) return;

        if (key == ESCAPE && !FlxG.keys.pressed.SHIFT) {
            close();
            cancelCallback();
            return;
        }
        close();
        callback(key);
        return;
    }
}