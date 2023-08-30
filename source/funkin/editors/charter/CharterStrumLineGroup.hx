package funkin.editors.charter;

import funkin.backend.chart.EventsData;
import flixel.util.FlxSort;

class CharterStrumLineGroup extends FlxTypedGroup<CharterStrumline> {
	var __pastStrumlines:Array<CharterStrumline>;
	var draggingObj:CharterStrumline = null;
	var draggingOffset:Float = 0;

	public var draggable:Bool = false;

	public override function update(elapsed:Float) {
		var mousePos = FlxG.mouse.getWorldPosition(cameras[0], FlxPoint.get());
		for (strumLine in members) {
			strumLine.draggable = draggable;
			if (draggable && UIState.state.isOverlapping(strumLine.draggingSprite, @:privateAccess strumLine.draggingSprite.__rect) && FlxG.mouse.justPressed) {
				draggingObj = strumLine;
				strumLine.dragging = true;

				draggingOffset = mousePos.x - strumLine.button.x;
				__pastStrumlines = members.copy();
				break;
			}
		}

		if (draggingObj != null)
			draggingObj.x = mousePos.x - draggingOffset;

		this.sort(function(o, a, b) return FlxSort.byValues(o, a.x, b.x), -1);
		for (i=>strum in members)
			if (!strum.dragging) strum.x = CoolUtil.fpsLerp(strum.x, 160 * i, 0.3);

		if (Charter.instance.eventsBackdrop != null)
			Charter.instance.eventsBackdrop.x = members[0].button.x - Charter.instance.eventsBackdrop.width;
		if (Charter.instance.strumlineLockButton != null)
			Charter.instance.strumlineLockButton.x = members[0].x - (40*4);
		if (Charter.instance.strumlineAddButton != null)
			Charter.instance.strumlineAddButton.x = members[members.length-1].x + (40*4);

		if ((FlxG.mouse.justReleased || !draggable) && draggingObj != null)
			finishDrag();

		mousePos.put();

		super.update(elapsed);
	}

	inline function finishDrag() {
		draggingObj.dragging = false;
		draggingObj = null;

		// Fix Events that use strumline param
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