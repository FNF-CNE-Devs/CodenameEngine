package funkin.editors.charter;

class CharterDeleteAnim extends CharterNote {
	public var garbageIcon:FlxSprite;

	public var deleteNotes:Array<{note:CharterNote, time:Float}> = [];
	public var deleteTime:Float = .4;

	public function new() {
		super();

		sustainSpr.color = 0xFF6D2425; color = 0xFF797171;
		snappedToStrumline = selectable = autoAlpha = false; 
		@:privateAccess __animSpeed = 1.25;

		garbageIcon = new FlxSprite().loadGraphic(Paths.image("editors/autosave-delete"));
		garbageIcon.color = 0xFF880000;
		garbageIcon.cameras = [Charter.instance.uiCamera];
	}

	var __garbageAlpha:Float = 0;
	var __deletionTimer:Float = .1;
	public override function update(elapsed:Float) {
		for (deleteData in deleteNotes) {
			deleteData.time -= elapsed;
			if (deleteData.time < 0) deleteNotes.remove(deleteData);
		}

		if (FlxG.mouse.justPressedRight) __deletionTimer = .1;
		__deletionTimer -= elapsed;

		__garbageAlpha = FlxMath.lerp(__garbageAlpha, FlxG.mouse.pressedRight && __deletionTimer <= 0 ? 1 : 0, 1/10);

		if (FlxG.mouse.pressedRight && __deletionTimer <= 0)
			garbageIcon.setPosition(
				FlxG.mouse.screenX + garbageIcon.width/2 + (.5*FlxG.random.float(-1, 1)), 
				FlxG.mouse.screenY - garbageIcon.height + (.5*FlxG.random.float(-1, 1))
			);
		garbageIcon.alpha = __garbageAlpha;
	}

	public override function draw() @:privateAccess {
		for (deleteData in deleteNotes) {
			y = deleteData.note.y + (deleteData.time>deleteTime*.5 ? (deleteData.time/deleteTime)*FlxG.random.float(-1.1, 1.1) : 0); // lunar when no shake :(( 
			x = deleteData.note.x + (deleteData.time>deleteTime*.5 ? (deleteData.time/deleteTime)*FlxG.random.float(-1.1, 1.1) : 0); // lunar when no shake :((
			angle = deleteData.note.angle; alpha = 1;
			animation.curAnim.curFrame = 3;

			sustainSpr.scale.set(10, (40 * deleteData.note.susLength) + (height/2));
			sustainSpr.updateHitbox(); sustainSpr.follow(this, 15, 20);
			sustainSpr.exists = deleteData.note.susLength != 0; sustainSpr.alpha = .8;

			typeText.text = Std.string(deleteData.note.type);
			typeText.exists = deleteData.note.type != 0; typeText.alpha = .4;
			typeText.follow(this, 20 - (typeText.frameWidth/2), 20 - (typeText.frameHeight/2));

			for (member in [this, sustainSpr, typeText]) 
				member.alpha *= FlxEase.quadInOut(deleteData.time/deleteTime);

			super.draw();
		}

		if (garbageIcon.alpha > 0) garbageIcon.draw();
	}
}