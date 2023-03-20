package funkin.editors.charter;

import flixel.tweens.FlxTween;
import funkin.shaders.CustomShader;
import flixel.util.FlxColor;

class CharterNote extends UISprite {
    private static var colors:Array<FlxColor> = [
        0xFFC24B99, // purple
        0xFF00FFFF, // cyan
        0xFF12FA05, // green
        0xFFF9393F  // red
    ];
    private static var colorsRotation:Array<FlxColor>;

    public static final noteScaleX:Float = 40 / 154;
    public static final noteScaleY:Float = 40 / 157;

    public var charterNoteShader:CustomShader;

    var angleTween:FlxTween;

    public function new() {
        super();
        antialiasing = true;
        loadGraphic(Paths.image('editors/charter/note'));
        scale.set(noteScaleX, noteScaleY);
        updateHitbox();
        scale.set(noteScaleY, noteScaleY);

        shader = charterNoteShader = new CustomShader('engine/charterNote');

        if (colorsRotation == null) colorsRotation = [
            colors[2],
            colors[3],
            colors[1],
            colors[0]
        ];

        angle = 45; // green-red inbetween
    }

    private override function set_angle(v:Float):Float {
        if (charterNoteShader != null) {
            var v2:Float = v;
            var o:Int = 0;

            // make sure the note isnt negative
            while(v2 < 0) {
                v2 += 90;
                o -= 1;
            }
            // make sure the note is under 90 degrees
            while(v2 > 90) {
                v2 -= 90;
                o += 1;
            }
            var c:FlxColor = FlxColor.interpolate(colorsRotation[FlxMath.wrap(o, 0, 3)], colorsRotation[FlxMath.wrap(o+1, 0, 3)], v2 / 90);

            charterNoteShader.hset('noteColor', [c.redFloat, c.greenFloat, c.blueFloat]);
        }
        return super.set_angle(v);
    }

    public function updatePos(step:Float, id:Int, susLength:Float = 0, type:Int = 0) {
        x = id * 40;
        y = step * 40;

        if (angleTween != null) angleTween.cancel();

        angleTween = FlxTween.tween(this, {angle: switch(id % 4) {
            case 0: -90;
            case 1: 180;
            case 2: 0;
            case 3: 90;
            default: 0; // how is that even possible
        }}, 1, {ease: function(t) {
            return ((Math.sin(t * Math.PI) * 0.35) * 3 * t * Math.sqrt(1 - t)) + t;
        }});
    }
}