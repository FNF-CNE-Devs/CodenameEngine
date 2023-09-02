package funkin.editors.charter;

import funkin.backend.system.Conductor;
import openfl.geom.Rectangle;
import flixel.addons.display.FlxBackdrop;

class CharterBackdrop extends FlxBackdrop {
	public var strumlinesAmount:Int = 1;

	public var topLimit:FlxSprite;
	public var topSeparator:FlxSprite;
	public var bottomLimit:FlxSprite;
	public var bottomSeparator:FlxSprite;

	public var conductorFollowerSpr:FlxSprite;
	public var beatSeparator:FlxBackdrop;
	public var sectionSeparator:FlxBackdrop;

	public var notesGroup:CharterNoteGroup;

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
			sep.makeSolid(1, 1, -1);
			sep.alpha = 0.5;
			sep.scrollFactor.set(1, 1);
			sep.scale.set((4 * 40), sep == sectionSeparator ? 4 : 2);
			sep.updateHitbox();
		}

		bottomSeparator = new FlxSprite(0,-2);
		bottomSeparator.makeSolid(1, 1, -1);
		bottomSeparator.alpha = 0.5;
		bottomSeparator.scrollFactor.set(1, 1);
		bottomSeparator.scale.set(4 * 40, 4);
		bottomSeparator.updateHitbox();

		topSeparator = new FlxSprite(0, -2);
		topSeparator.makeSolid(1, 1, -1);
		topSeparator.alpha = 0.5;
		topSeparator.scrollFactor.set(1, 1);
		topSeparator.scale.set(4 * 40, 4);
		topSeparator.updateHitbox();

		// Limits
		topLimit = new FlxSprite();
		topLimit.makeSolid(1, 1, -1);
		topLimit.color = 0xFF888888;
		topLimit.blend = MULTIPLY;

		bottomLimit = new FlxSprite();
		bottomLimit.makeSolid(1, 1, -1);
		bottomLimit.color = 0xFF888888;
		bottomLimit.blend = MULTIPLY;

		// Follower
		conductorFollowerSpr = new FlxSprite(0, 0).makeSolid(1, 1, -1);
		conductorFollowerSpr.scale.set(4 * 40, 4);
		conductorFollowerSpr.updateHitbox();
	}

	public override function draw() {
		var ogX:Float = x;
		//FlxG.watch.addQuick("gridXs", [for (strum in Charter.instance.strumLines.members) strum.x]);
		for(_ in 0...strumlinesAmount) {
			if (Charter.instance.strumLines.members[_] != null) {
				x = Charter.instance.strumLines.members[_].x;
				alpha = Charter.instance.strumLines.members[_].strumLine.visible ? 0.9 : 0.4;
			} else alpha = 0.9;

			sectionSeparator.spacing.y = (10 * Conductor.beatsPerMesure * Conductor.stepsPerBeat) - 1;
			beatSeparator.spacing.y = (20 * Conductor.stepsPerBeat) - 1;
			
			super.draw();

			for (sep in [sectionSeparator, beatSeparator]) {
				sep.x = this.x;
				sep.cameras = this.cameras;
				if (sep.visible) sep.draw();
			}

			topLimit.x = this.x;
			topLimit.cameras = this.cameras;

			notesGroup.forEach((n) -> {
				if(n.exists && n.visible) {
					n.cameras = cameras;
					n.draw();
				}
			});

			topLimit.scale.set(4 * 40, Math.ceil(FlxG.height / cameras[0].zoom));
			topLimit.updateHitbox();
			topLimit.y = -topLimit.height;
			topLimit.draw();

			bottomLimit.x = this.x;
			bottomLimit.cameras = this.cameras;
	
			bottomLimit.scale.set(4 * 40, Math.ceil(FlxG.height / cameras[0].zoom));
			bottomLimit.updateHitbox();
			bottomLimit.draw();

			topSeparator.x = this.x;
			topSeparator.cameras = this.cameras;
			if (!sectionSeparator.visible) topSeparator.draw();

			bottomSeparator.x = this.x;
			bottomSeparator.cameras = this.cameras;
			bottomSeparator.draw();

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

class EventBackdrop extends FlxBackdrop {
	public var eventBeatSeparator:FlxBackdrop;
	public var eventSecSeparator:FlxBackdrop;

	public var topSeparator:FlxSprite;
	public var bottomSeparator:FlxSprite;

	public function new() {
		super(Paths.image('editors/charter/events-grid'), Y, 0, 0);
		alpha = 0.9;

		// Separators
		eventSecSeparator = new FlxBackdrop(null, Y, 0, 0);
		eventSecSeparator.y = -2;
		eventSecSeparator.visible = Options.charterShowSections;

		eventBeatSeparator = new FlxBackdrop(null, Y, 0, 0);
		eventBeatSeparator.y = -1;
		eventBeatSeparator.visible = Options.charterShowBeats;

		for(sep in [eventSecSeparator, eventBeatSeparator]) {
			sep.makeSolid(1, 1, -1);
			sep.alpha = 0.5;
			sep.scrollFactor.set(1, 1);
		}

		eventSecSeparator.scale.set(20, 4);
		eventSecSeparator.updateHitbox();

		eventBeatSeparator.scale.set(10, 2);
		eventBeatSeparator.updateHitbox();

		bottomSeparator = new FlxSprite(0,-2);
		bottomSeparator.makeSolid(1, 1, -1);
		bottomSeparator.alpha = 0.5;
		bottomSeparator.scrollFactor.set(1, 1);
		bottomSeparator.scale.set(20, 4);
		bottomSeparator.updateHitbox();

		topSeparator = new FlxSprite(0, -2);
		topSeparator.makeSolid(1, 1, -1);
		topSeparator.alpha = 0.5;
		topSeparator.scrollFactor.set(1, 1);
		topSeparator.scale.set(20, 4);
		topSeparator.updateHitbox();

	}

	public override function draw() {
		super.draw();

		eventSecSeparator.spacing.y = (10 * Conductor.beatsPerMesure * Conductor.stepsPerBeat) - 1;
		eventBeatSeparator.spacing.y = (20 * Conductor.stepsPerBeat) - 1;

		eventSecSeparator.cameras = cameras;
		eventSecSeparator.x = (x+width) - 20;
		if (eventSecSeparator.visible) eventSecSeparator.draw();

		eventBeatSeparator.cameras = cameras;
		eventBeatSeparator.x = (x+width) - 10;
		if (eventBeatSeparator.visible) eventBeatSeparator.draw();

		topSeparator.x = (x+width) - 20;
		topSeparator.cameras = this.cameras;
		if (!eventSecSeparator.visible) topSeparator.draw();

		bottomSeparator.x = (x+width) - 20;
		bottomSeparator.cameras = this.cameras;
		bottomSeparator.draw();
	}
}