package funkin.menus;

import flixel.addons.transition.FlxTransitionableState;
import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.text.FlxText;
import funkin.ui.Alphabet;
import funkin.ui.FunkinText;

class BetaWarningState extends MusicBeatState {
    var titleAlphabet:Alphabet;
    var disclaimer:FunkinText;

    var transitioning:Bool = false;

    public override function create() {
        super.create();

        titleAlphabet = new Alphabet(0, 0, "WARNING", true);
        titleAlphabet.screenCenter(X);
        add(titleAlphabet);

        disclaimer = new FunkinText(16, titleAlphabet.y + titleAlphabet.height + 10, FlxG.width - 32, "", 32);
        disclaimer.alignment = CENTER;
        disclaimer.applyMarkup("This engine is still in a beta state. That means *majority of the features* are either *buggy* or *non finished*. If you find any bug, please report them to the Codename Engine GitHub.\n\nPress ENTER to continue",
            [
                new FlxTextFormatMarkerPair(new FlxTextFormat(0xFFFF4444), "*")
            ]
        );
        add(disclaimer);

        var off = Std.int((FlxG.height - (disclaimer.y + disclaimer.height)) / 2);
        disclaimer.y += off;
        titleAlphabet.y += off;
    }

    public override function update(elapsed:Float) {
        super.update(elapsed);

        if (controls.ACCEPT && !transitioning) {
            transitioning = true;
            CoolUtil.playMenuSFX(1);
            FlxG.camera.flash(FlxColor.WHITE, 1, function() {
                FlxG.camera.fade(FlxColor.BLACK, 2.5, false, function() {
                    FlxTransitionableState.skipNextTransIn = FlxTransitionableState.skipNextTransOut = true;
                    FlxG.switchState(new TitleState());
                });
            });
        }
    }
}