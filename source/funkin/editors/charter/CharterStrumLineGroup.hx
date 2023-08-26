package funkin.editors.charter;

import funkin.backend.chart.EventsData;
import flixel.util.FlxSort;

class CharterStrumLineGroup extends FlxTypedGroup<CharterStrumline> {
	var __pastStrumlines:Array<CharterStrumline>;
	var draggingObj:CharterStrumline = null;
	var draggingOffset:Float = 0;

	public override function update(elapsed:Float) {
		super.update(elapsed);

		for (strumLine in members) {
			if (FlxG.mouse.overlaps(strumLine.healthIcon) && FlxG.mouse.justPressed) {
				draggingObj = strumLine;
				strumLine.dragging = true;

				draggingOffset = FlxG.mouse.x - strumLine.button.x;
				__pastStrumlines = members.copy();
				break;
			}
		}

		if (draggingObj != null)
			draggingObj.x = FlxG.mouse.x - draggingOffset;


		this.sort(function(o, a, b) return FlxSort.byValues(o, a.x, b.x), -1);
		for (i=>strum in members)
			if (!strum.dragging) strum.x = CoolUtil.fpsLerp(strum.x, 160 * i, 0.3);

		Charter.instance.eventsBackdrop.x = members[0].button.x - Charter.instance.eventsBackdrop.width;

		if (FlxG.mouse.justReleased && draggingObj != null) {
			draggingObj.dragging = false;
			draggingObj = null;

			// Fix Events that use strumline param
			for (i in Charter.instance.eventsGroup.members) {
				for (j in i.events) {
					var paramTypes:Array<EventParamInfo> = EventsData.getEventParams(j.name);
					for (i => param in paramTypes) {
						if (param.type != TStrumLine) continue;
						j.params[i] = Charter.instance.strumLines.members.indexOf(__pastStrumlines[j.params[i]]);
					}
				}
			}
			
			__pastStrumlines = null;	
		}
	}
}