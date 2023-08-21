package funkin.editors.charter;

import openfl.geom.Rectangle;
import flixel.addons.display.FlxBackdrop;

class CharterBackdrop extends FlxBackdrop {
	public var strumlinesAmount:Int = 1;
	public var yMult:Float = 1;
	public function new() {
		super(null, Y, 0, 0);
		refreshDrawing();
	}

	public function refreshDrawing() {
		makeGraphic(160, Std.int(160/yMult), 0xFF272727, true);
		pixels.lock();

		// Checkerboard
		for(y in 0...Std.int(4))
			for(x in 0...2)
				pixels.fillRect(new Rectangle(40*((x*2)+(y%2)), (40/yMult)*y, 40, (40/yMult)), 0xFF545454);

		// Edges
		pixels.fillRect(new Rectangle(0, 0, 1, 160), 0xFFDDDDDD);
		pixels.fillRect(new Rectangle(159, 0, 1, 160), 0xFFDDDDDD);
		pixels.unlock();
		// loadFrame(frame);	
	}

	public override function draw() {
		var ogX:Float = x;
		for(_ in 0...strumlinesAmount) {
			if (Charter.instance.strumLines.members[_] != null)
				alpha = Charter.instance.strumLines.members[_].strumLine.visible ? 1 : 0.4;
			else alpha = 0.9;
			super.draw();
			x += width;
		}
		x = ogX;
	}
}

class CharterBackdropDummy extends UISprite {
	public var parent:CharterBackdrop;
	public function new(parent:CharterBackdrop) {
		super();
		this.parent = parent;
		cameras = parent.cameras;
		scrollFactor.set(1, 0);
	}

	public override function updateButton() {
		camera.getViewRect(__rect);
		UIState.state.updateRectButtonHandler(this, __rect, onHovered);
	}

	public override function draw() {
		@:privateAccess
		__lastDrawCameras = [for(c in cameras) c];
	}
}
