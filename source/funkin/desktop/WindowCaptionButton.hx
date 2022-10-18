package funkin.desktop;

import flixel.addons.ui.FlxUIButton;
import flixel.FlxSprite;

class WindowCaptionButton extends FlxUIButton {
    public var icon:FlxSprite;

    public function new(window:Window, i:Int) {
        super(0, 0, "", function() {
            switch(i) {
                default:
                    trace(i);
            }
        });
        ID = i;
        resize(18, 18);
        color = (i > 0) ? 0xFF8888FF : 0xFFFF0000;

        icon = new FlxSprite(0, 0).loadGraphic(Paths.image('desktop/captionButtons'), true, 18, 18);
        icon.animation.add("button", [switch(i) {
            case 0: 2;
            case 1: 1;
            case 2: 0;
            default: i;
        }]);
        icon.animation.play("button");
    }

    public override function draw() {
        super.draw();

        icon.setPosition(x, y);
        icon.cameras = this.cameras;
        icon.draw();
        icon.scrollFactor.set(scrollFactor.x, scrollFactor.y);
    }
}