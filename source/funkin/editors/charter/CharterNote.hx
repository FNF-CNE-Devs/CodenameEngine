package funkin.editors.charter;

import flixel.math.FlxPoint;
import funkin.editors.charter.Charter.ICharterSelectable;
import funkin.backend.system.Conductor;
import flixel.tweens.FlxTween;
import funkin.backend.shaders.CustomShader;
import flixel.util.FlxColor;

class CharterNote extends UISprite implements ICharterSelectable {
	var angleTween:FlxTween;

	private static var colors:Array<FlxColor> = [
		0xFFC24B99,
		0xFF00FFFF,
		0xFF12FA05,
		0xFFF9393F
	];

	public var sustainSpr:FlxSprite;
	var __doAnim:Bool = false;

	public var selected:Bool = false;
	public var draggable:Bool = true;

	public function new() {
		super();
		antialiasing = true;
		loadGraphic(Paths.image('editors/charter/note'), true, 157, 154);
		animation.add("note", [for(i in 0...frames.frames.length) i], 0, true);
		animation.play("note");
		this.setUnstretchedGraphicSize(40, 40, false);

		cursor = BUTTON;

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

	public var strumLine:CharterStrumline;
	public var strumLineID(get, never):Int;
	public function get_strumLineID():Int
		return strumLine == null ? -1 : Charter.instance.strumLines.members.indexOf(strumLine);

	public var snappedToStrumline:Bool = true;

	public var fullID(get, never):Int; // instead of %4 get fullID (for mousepos stuff)
	public function get_fullID():Int
		return (strumLineID * 4) + id;

	public function updatePos(step:Float, id:Int, susLength:Float = 0, ?type:Int = 0, ?strumLine:CharterStrumline = null) {
		this.step = step;
		this.id = id;
		this.susLength = susLength;
		this.type = type;
		if (strumLine != null) this.strumLine = strumLine;
		y = step * 40;

		sustainSpr.scale.set(10, (40 * susLength));
		sustainSpr.updateHitbox();
		sustainSpr.exists = susLength != 0;
		sustainSpr.alpha = alpha;

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

		if(sustainSpr.exists)
			sustainSpr.follow(this, 15, 20);

		if (__passed != (__passed = step < Conductor.curStepFloat)) {
			if (__passed && FlxG.sound.music.playing && Charter.instance.hitsoundsEnabled(strumLineID))
				Charter.instance.hitsound.replay();
		}

		alpha = strumLine != null && !strumLine.strumLine.visible ? (__passed ? 0.2 : 0.4) : (__passed ? 0.6 : 1); 
		if(sustainSpr.exists) sustainSpr.alpha = alpha;

		colorTransform.redMultiplier = colorTransform.greenMultiplier = colorTransform.blueMultiplier = selected ? 0.75 : 1;
		colorTransform.redOffset = colorTransform.greenOffset = selected ? 96 : 0;
		colorTransform.blueOffset = selected ? 168 : 0;

		__doAnim = true;
	}

	public function handleSelection(selectionBox:UISliceSprite):Bool {
		var minX = Std.int(selectionBox.x / 40);
		var minY = (selectionBox.y / 40) - 1;
		var maxX = Std.int(Math.ceil((selectionBox.x + selectionBox.bWidth) / 40));
		var maxY = ((selectionBox.y + selectionBox.bHeight) / 40);

		return this.fullID >= minX && this.fullID < maxX && this.step >= minY && this.step < maxY;
	}

	public function handleDrag(change:FlxPoint) {
		var newStep = FlxMath.bound(step + change.x, 0, Charter.instance.__endStep-1);
		var newID:Int = Std.int(FlxMath.bound(fullID + Std.int(change.y), 0, (Charter.instance.strumLines.members.length*4)-1));

		updatePos(newStep, newID % 4, susLength, type, Charter.instance.strumLines.members[Std.int(newID/4)]);
	}

	public override function draw() {
		if (snappedToStrumline)
			x = (strumLine != null ? strumLine.x : 0) + (id % 4) * 40;

		drawMembers();
		drawSuper();
	}
}