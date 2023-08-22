package funkin.editors.charter;

import flixel.tweens.misc.VarTween;
import flixel.tweens.FlxTween;

class ChartHoverNote extends UISprite {
	public var angleTween:FlxTween;

	public var onGrid:Bool = false;
	public var id:Int = 0;
	public var nextID:Int = 0;

	public function new() {
		super();
		antialiasing = true;
		loadGraphic(Paths.image('editors/charter/note'), true, 157, 154);
		animation.add("note", [for(i in 0...frames.frames.length) i], 0, true);
		animation.play("note");
		this.setUnstretchedGraphicSize(40, 40, false);

		moves = selectable = false;
		colorTransform.color = 0xFFFFFF;
	}

	public override function update(elapsed:Float) {
		super.update(elapsed);

		var mousePos = FlxG.mouse.getWorldPosition(__lastDrawCameras[0]);
		alpha = FlxMath.lerp(alpha, onGrid ? 0.2 : 0, 1/8);
		id = Math.floor(x / 40);

		if (onGrid) {
			Charter.instance.gridBackdropDummy.cursor = BUTTON;
			x = (nextID = Math.floor(mousePos.x / 40)) * 40;
			y = (FlxG.keys.pressed.SHIFT ? (mousePos.y / 40) : Math.floor(mousePos.y / 40)) * 40;

			if (id != nextID) {
				if (angleTween != null) angleTween.cancel();

				angle = switch(id % 4) {
					case 0: -90;
					case 1: 180;
					case 2: 0;
					case 3: 90;
					default: 0; // how is that even possible
				};
				
				var destAngle = switch((nextID % 4)) {
					case 0: -90;
					case 1: 180;
					case 2: 0;
					case 3: 90;
					default: 0; // how is that even possible
				};

				angleTween = FlxTween.tween(this, {angle: destAngle}, 2/3, {ease: function(t) {
					return ((Math.sin(t * Math.PI) * 0.35) * 3 * t * Math.sqrt(1 - t)) + t;
				}, onComplete: function (t) {angleTween = null;}});
			}
		} else if (alpha > 0) {
			Charter.instance.gridBackdropDummy.cursor = ARROW;
			x = mousePos.x - 20; y = mousePos.y -20;
		}
		mousePos.put();
	}
}