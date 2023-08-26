package funkin.editors.charter;

import funkin.backend.system.Conductor;
import openfl.geom.Rectangle;
import flixel.addons.display.FlxBackdrop;

class CharterBackdrop extends FlxBackdrop {
	public var strumlinesAmount:Int = 1;

	public var conductorFollowerSpr:FlxSprite;
	public var beatSeparator:FlxBackdrop;
	public var sectionSeparator:FlxBackdrop;

	public function new() {
		super(null, Y, 0, 0);

		makeGraphic(160, 160, 0xFF272727, true);
		pixels.lock();

		// Checkerboard
		for(y in 0...4)
			for(x in 0...2)
				pixels.fillRect(new Rectangle(40*((x*2)+(y%2)), 40*y, 40, 40), 0xFF545454);

		// Edges
		pixels.fillRect(new Rectangle(0, 0, 1, 160), 0xFFDDDDDD);
		pixels.fillRect(new Rectangle(159, 0, 1, 160), 0xFFDDDDDD);
		pixels.unlock();
		
		// Seperators 
		sectionSeparator = new FlxBackdrop(null, Y, 0, 0);
		sectionSeparator.y = -2;
		sectionSeparator.visible = Options.charterShowSections;

		beatSeparator = new FlxBackdrop(null, Y, 0, 0);
		beatSeparator.y = -1;
		beatSeparator.visible = Options.charterShowBeats;
		
		for(sep in [sectionSeparator, beatSeparator]) {
			sep.makeGraphic(1, 1, -1);
			sep.alpha = 0.5;
			sep.scrollFactor.set(1, 1);
			sep.scale.set((4 * 40), sep == sectionSeparator ? 4 : 2);
			sep.updateHitbox();
		}

		// Follower
		conductorFollowerSpr = new FlxSprite(0, 0).makeGraphic(1, 1, -1);
		conductorFollowerSpr.scale.set(4 * 40, 4);
		conductorFollowerSpr.updateHitbox();
	}

	public override function draw() {
		var ogX:Float = x;
		for(_ in 0...strumlinesAmount) {
			if (Charter.instance.strumLines.members[_] != null) {
				x = Charter.instance.strumLines.members[_].x;
				alpha = Charter.instance.strumLines.members[_].strumLine.visible ? 1 : 0.4;
			} else alpha = 0.9;

			sectionSeparator.spacing.y = (10 * Conductor.beatsPerMesure * Conductor.stepsPerBeat) - 1;
			beatSeparator.spacing.y = (20 * Conductor.stepsPerBeat) - 1;
			
			super.draw();

			for (sep in [sectionSeparator, beatSeparator]) {
				sep.x = this.x;
				sep.cameras = this.cameras;
				if (sep.visible) sep.draw();
			}

			conductorFollowerSpr.x = this.x;
			conductorFollowerSpr.cameras = this.cameras;
			if (conductorFollowerSpr.visible) conductorFollowerSpr.draw();
		}
		x = ogX;
	}
}

class CharterBackdropDummy extends UISprite {
	var parent:CharterBackdrop;
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