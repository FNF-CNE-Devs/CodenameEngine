package funkin.editors.charter;

import flixel.tweens.FlxTween;
import funkin.shaders.CustomShader;
import flixel.util.FlxColor;

class CharterNote extends UISprite {
    var angleTween:FlxTween;

    public function new() {
        super();
        antialiasing = true;
        loadGraphic(Paths.image('editors/charter/note'), true, 157, 154);
        animation.add("note", [for(i in 0...frames.frames.length) i], 0, true);
        animation.play("note");
        this.setUnstretchedGraphicSize(40, 40, false);

        angle = 45; // green-red inbetween
    }

    public function updatePos(step:Float, id:Int, susLength:Float = 0, type:Int = 0) {
        x = id * 40;
        y = step * 40;

        if (angleTween != null) angleTween.cancel();

        angleTween = FlxTween.tween(this, {angle: switch(animation.curAnim.curFrame = (id % 4)) {
            case 0: -90;
            case 1: 180;
            case 2: 0;
            case 3: 90;
            default: 0; // how is that even possible
        }}, 2/3, {ease: function(t) {
            return ((Math.sin(t * Math.PI) * 0.35) * 3 * t * Math.sqrt(1 - t)) + t;
        }});
    }
}