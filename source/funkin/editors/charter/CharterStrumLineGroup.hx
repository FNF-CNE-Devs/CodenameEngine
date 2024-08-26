package funkin.editors.charter;

import funkin.backend.chart.EventsData;
import flixel.util.FlxSort;

class CharterStrumLineGroup extends FlxTypedGroup<CharterStrumline> {
	var __pastStrumlines:Array<CharterStrumline>;
	var draggingObj:CharterStrumline = null;
	var draggingOffset:Float = 0;

	public var totalKeyCount(get, never):Int;
	public function get_totalKeyCount():Int {
		var v:Int = 0;
		for (strumLine in members) v += strumLine.keyCount;
		return v;
	}

	public var draggable:Bool = false;
	public var isDragging(get, never):Bool;
	public function get_isDragging():Bool
		return draggingObj != null;

	public override function update(elapsed:Float) {
		var mousePos = FlxG.mouse.getWorldPosition(cameras[0], FlxPoint.get());
		for (strumLine in members) {
			if (strumLine == null) continue;
			strumLine.draggable = draggable;
			if (draggable && UIState.state.isOverlapping(strumLine.draggingSprite, @:privateAccess strumLine.draggingSprite.__rect) && FlxG.mouse.justPressed) {
				draggingObj = strumLine;
				strumLine.dragging = true;

				draggingOffset = mousePos.x - strumLine.button.x;
				__pastStrumlines = members.copy();
				break;
			}
		}

		if (isDragging) {
			draggingObj.x = mousePos.x - draggingOffset;
			this.sort(function(o, a, b) return FlxSort.byValues(o, a.x, b.x), -1);
		}

		for (i=>strum in members)
			if (strum != null && !strum.dragging) strum.x = CoolUtil.fpsLerp(strum.x, 40*strum.startingID, 0.225);

		if (Charter.instance.eventsBackdrop != null && members[0] != null)
			Charter.instance.eventsBackdrop.x = members[0].button.x - Charter.instance.eventsBackdrop.width;
		if (Charter.instance.strumlineLockButton != null && members[0] != null)
			Charter.instance.strumlineLockButton.x = members[0].x - (160);
		if (Charter.instance.strumlineAddButton != null && members[Std.int(Math.max(0, members.length-1))] != null)
			Charter.instance.strumlineAddButton.x = members[members.length-1].x + (40*members[members.length-1].keyCount);

		if ((FlxG.mouse.justReleased || !draggable) && isDragging)
			finishDrag();

		mousePos.put();
		super.update(elapsed);
	}

	public function snapStrums() {
		for (i=>strum in members)
			if (strum != null && !strum.dragging) strum.x = 40*strum.startingID;
	}

	public function orderStrumline(strumLine:CharterStrumline, newID:Int) {
		__pastStrumlines = members.copy();

		members.remove(strumLine);
		members.insert(newID, strumLine);

		finishDrag(false);
	}

	public function finishDrag(?addToUndo:Bool = true) {
		if (isDragging)
			draggingObj.dragging = false;

		// Undo
		if (addToUndo) {
			var oldID = __pastStrumlines.indexOf(draggingObj);
			var newID = members.indexOf(draggingObj);
			if (newID != oldID) Charter.undos.addToUndo(COrderStrumLine(newID, oldID, newID));
		}

		draggingObj = null;
		fixEvents();
	}

	public inline function fixEvents() {
		for (i in Charter.instance.eventsGroup.members) {
			for (j in i.events) {
				var paramTypes:Array<EventParamInfo> = EventsData.getEventParams(j.name);
				for (i => param in paramTypes) {
					if (param.type != TStrumLine) continue;
					j.params[i] = members.indexOf(__pastStrumlines[j.params[i]]);
				}
			}
		}
		__pastStrumlines = null;
	}

	public function getStrumlineFromID(id:Int) {
		var v:Int = 0;
		for (strumLine in members) {
			v += strumLine.keyCount;
			if (id < v) return strumLine;
		}
		return members[0]; //how?
	}

	override function draw() @:privateAccess {
		var i:Int = 0;
		var basic:FlxBasic = null;

		var oldDefaultCameras = FlxCamera._defaultCameras;
		if (cameras != null)
			FlxCamera._defaultCameras = cameras;

		while (i < length)
		{
			basic = members[i++];
			if (basic != null && basic != draggingObj && basic.exists && basic.visible)
				basic.draw();
		}
		if (draggingObj != null) draggingObj.draw();

		FlxCamera._defaultCameras = oldDefaultCameras;
	}
}