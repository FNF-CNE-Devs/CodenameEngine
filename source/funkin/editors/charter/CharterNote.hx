package funkin.editors.charter;

import flixel.tweens.FlxTween;
import funkin.shaders.CustomShader;
import flixel.util.FlxColor;

class CharterNote extends UISprite {
    var angleTween:FlxTween;

    public var selected:Bool = false;

    public function new() {
        super();
        antialiasing = true;
        loadGraphic(Paths.image('editors/charter/note'), true, 157, 154);
        animation.add("note", [for(i in 0...frames.frames.length) i], 0, true);
        animation.play("note");
        this.setUnstretchedGraphicSize(40, 40, false);

        angle = 45; // green-red inbetween

        cursor = BUTTON;

		moves = false;
    }


	public var step:Float;
	public var id:Int;
	public var susLength:Float;
	public var type:Int;

    public function updatePos(step:Float, id:Int, susLength:Float = 0, type:Int = 0) {
		this.step = step;
		this.id = id;
		this.susLength = susLength;
		this.type = type;
		
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

	public override function kill() {
		if (angleTween != null) {
			angleTween.cancel();
			angle = switch(animation.curAnim.curFrame = (id % 4)) {
				case 0: -90;
				case 1: 180;
				case 2: 0;
				case 3: 90;
				default: 0; // how is that even possible
			};
		}
		super.kill();
	}

    public override function update(elapsed:Float) {
		super.update(elapsed);
		
        colorTransform.redMultiplier = colorTransform.greenMultiplier = colorTransform.blueMultiplier = selected ? 0.75 : 1;
        colorTransform.redOffset = colorTransform.greenOffset = selected ? 96 : 0;
		colorTransform.blueOffset = selected ? 168 : 0;
    }
}