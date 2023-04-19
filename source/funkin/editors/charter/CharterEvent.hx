package funkin.editors.charter;

import funkin.game.HealthIcon;
import funkin.backend.chart.ChartData.ChartEvent;

class CharterEvent extends UISliceSprite {
	public static function getEventInfo(id:Int) {
		return switch(id) {
			case -1:
				// hscript
				{
					name: "HScript Parameters"
				}
			default:
				{
					name: "Unknown",
					params: []
				}
		};
	}

	public var events:Array<ChartEvent>;

	public var step:Float;

	public var icons:Array<FlxSprite> = [];

	public function new(step:Float, ?events:Array<ChartEvent>) {
		super(-100, step * 40, 100, 34, 'editors/charter/event-spr');
		this.step = step;
		this.events = events.getDefault([]);

		refreshEventIcons();
	}

	public function refreshEventIcons() {
		while(icons.length > 0) {
			var i = icons.shift();
			members.remove(i);
			i.destroy();
		}

		var f = function(type) {
			var spr = new FlxSprite().loadGraphic(Paths.image('editors/charter/event-icons'), true, 16, 16);
			spr.frame = spr.frames.frames[type];
			icons.push(spr);
			members.push(spr);
		};

		for(event in events) {
			switch(event.type) {
				default:
					f(event.type);
				case CAM_MOVEMENT:
					// custom icon for camera movement
					var state = cast(FlxG.state, Charter);
					if (event.params[0] != null && event.params[0] >= 0 && event.params[0] < state.strumLines.length) {
						// camera movement, use health icon
						var healthIcon = new HealthIcon('${event.params[0]}');
						healthIcon.setGraphicSize(24, 24);
						healthIcon.updateHitbox();
						icons.push(healthIcon);
						members.push(healthIcon);
					} else
						f(event.type);
			}
		}
	}
}

typedef EventInfo = {
	var name:String;
	var params:Array<EventParamType>;
	var paramValues:Array<Dynamic>;
}

enum EventParamType {
	TBool;
	TInt(?min:Int, ?max:Int);
	TFloat(?min:Int, ?max:Int);
	TString;
	TArrayOfString;
}