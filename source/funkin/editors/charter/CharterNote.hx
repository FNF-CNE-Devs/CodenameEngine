package funkin.editors.charter;

import funkin.backend.system.Conductor;
import flixel.tweens.FlxTween;
import funkin.backend.shaders.CustomShader;
import flixel.util.FlxColor;

class CharterNote extends UISprite {
	var angleTween:FlxTween;

	private static var colors:Array<FlxColor> = [
		0xFFC24B99,
		0xFF00FFFF,
		0xFF12FA05,
		0xFFF9393F
	];

	public var sustainSpr:FlxSprite;
	public var selected:Bool = false;

	var __doAnim:Bool = false;

	public function new() {
		super();
		antialiasing = true;
		loadGraphic(Paths.image('editors/charter/note'), true, 157, 154);
		animation.add("note", [for(i in 0...frames.frames.length) i], 0, true);
		animation.play("note");
		this.setUnstretchedGraphicSize(40, 40, false);

		cursor = BUTTON;

		//canBeHovered = false;

		moves = false;

		sustainSpr = new FlxSprite(10, 40);
		sustainSpr.makeGraphic(1, 1, -1);
		members.push(sustainSpr);
	}

	public override function updateButtonHandler() {
		__rect.x = x;
		__rect.y = y;
		__rect.width = 40;
		__rect.height = 40;
		UIState.state.updateRectButtonHandler(this, __rect, onHovered);
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

		sustainSpr.scale.set(10, (40 * susLength));
		sustainSpr.updateHitbox();

		if (angleTween != null) angleTween.cancel();

		var destAngle = switch(animation.curAnim.curFrame = (id % 4)) {
			case 0: -90;
			case 1: 180;
			case 2: 0;
			case 3: 90;
			default: 0; // how is that even possible
		};

		sustainSpr.color = colors[animation.curAnim.curFrame];

		if (!__doAnim) {
			angle = destAngle;
			return;
		}

		if (angle == destAngle) return;

		if(angleTween != null)
			angleTween.cancel();

		angleTween = FlxTween.tween(this, {angle: destAngle}, 2/3, {ease: function(t) {
			return ((Math.sin(t * Math.PI) * 0.35) * 3 * t * Math.sqrt(1 - t)) + t;
		}});
	}

	public override function kill() {
		if (angleTween != null) {
			angleTween.cancel();
			angleTween = null;
			angle = switch(animation.curAnim.curFrame = (id % 4)) {
				case 0: -90;
				case 1: 180;
				case 2: 0;
				case 3: 90;
				default: 0; // how is that even possible
			};
			__doAnim = false;
		}
		super.kill();
	}

	var __passed:Bool = false;
	public override function update(elapsed:Float) {
		super.update(elapsed);

		sustainSpr.follow(this, 15, 20);

		if (__passed != (__passed = step < Conductor.curStepFloat)) {
			alpha = __passed ? 0.6 : 1;
			if (__passed && FlxG.sound.music.playing && Charter.instance.hitsoundsEnabled(id))
				Charter.instance.hitsound.replay();
		}
		sustainSpr.alpha = alpha;

		colorTransform.redMultiplier = colorTransform.greenMultiplier = colorTransform.blueMultiplier = selected ? 0.75 : 1;
		colorTransform.redOffset = colorTransform.greenOffset = selected ? 96 : 0;
		colorTransform.blueOffset = selected ? 168 : 0;

		__doAnim = true;
	}

	public override function draw() {
		drawMembers();
		drawSuper();
	}
}