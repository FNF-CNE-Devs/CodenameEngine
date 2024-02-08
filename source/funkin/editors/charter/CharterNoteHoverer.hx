package funkin.editors.charter;

class CharterNoteHoverer extends CharterNote {
	public function new() {
		super();

		snappedToStrumline = selectable = autoAlpha = false; visible = sustainSpr.visible = false;
		@:privateAccess __animSpeed = 1.25; typeText.visible = false; alpha = 0.4;
	}

	@:noCompletion var __mousePos:FlxPoint = FlxPoint.get();
	public override function update(elapsed:Float) @:privateAccess {
		FlxG.mouse.getWorldPosition(FlxG.camera, __mousePos);

		var inBoundsY:Bool = (__mousePos.y > 0 && __mousePos.y < (Charter.instance.__endStep)*40);
		if (__mousePos.x > 0 && __mousePos.x < Charter.instance.gridBackdrops.strumlinesAmount * 160 && inBoundsY) {
			step = FlxMath.bound(FlxG.keys.pressed.SHIFT ? ((__mousePos.y-20) / 40) : Charter.instance.quantStep(__mousePos.y/40), 0, Charter.instance.__endStep-1);
			id = Math.floor(__mousePos.x / 40); y = step * 40; x = id * 40; visible = true;
			angle = switch(animation.curAnim.curFrame = (id % 4)) {
				case 0: -90;
				case 1: 180;
				case 2: 0;
				case 3: 90;
				default: 0; // how is that even possible
			};
		} else
			visible = false;
	}

	public override function draw() @:privateAccess {
		if (Charter.instance.gridActionType == NONE) super.draw();
		if (Charter.instance.gridActionType == DRAG) {
			visible = true; __doAnim = false;

			var verticalChange:Float = (__mousePos.y - Charter.instance.dragStartPos.y) / 40;
			var horizontalChange:Int = CoolUtil.floorInt((__mousePos.x - (Std.int(Charter.instance.dragStartPos.x / 40) * 40)) / 40);

			for (s in Charter.selection) {
				if (s != null && s.draggable && s is CharterNote) {
					var draggingNote:CharterNote = cast(s, CharterNote);
					y = ((draggingNote.step + verticalChange) - ((draggingNote.step + verticalChange)
					- Charter.instance.quantStepRounded(draggingNote.step+verticalChange, verticalChange > 0 ? 0.35 : 0.65))) * 40;
					var newID:Int = Std.int(FlxMath.bound(draggingNote.fullID + horizontalChange, 0, (Charter.instance.strumLines.members.length*4)-1));
					x = (id=newID) * 40;

					angle = switch(animation.curAnim.curFrame = (draggingNote.id % 4)) {
						case 0: -90;
						case 1: 180;
						case 2: 0;
						case 3: 90;
						default: 0; // how is that even possible
					};
					super.draw();
				}
			}
		}
	}

	public override function destroy() {
		super.destroy();
		__mousePos.put();
	}
}