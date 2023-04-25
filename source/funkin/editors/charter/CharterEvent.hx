package funkin.editors.charter;

import funkin.backend.system.Conductor;
import funkin.backend.chart.ChartData.ChartEventType;
import funkin.game.HealthIcon;
import funkin.backend.chart.ChartData.ChartEvent;

class CharterEvent extends UISliceSprite {
	public static function getEventInfo(id:ChartEventType):EventDefineInfo {
		return switch(id) {
			case CUSTOM:
				// hscript
				{
					name: "HScript Call",
					params: [
						{
							name: "Function name",
							type: TString,
							defValue: "myFunc"
						},
						{
							name: "Function parameters (string)",
							type: TArrayOfString,
							defValue: []
						}
					]
				}
			case CAM_MOVEMENT:
				{
					name: "Camera Movement",
					params: [
						{
							name: "Camera Target",
							type: TStrumLine,
							defValue: 0
						}
					]
				}
			case BPM_CHANGE:
				{
					name: "BPM Change",
					params: [
						{
							name: "Target BPM",
							type: TFloat(1),
							defValue: Conductor.bpm
						}
					]
				}
			case ALT_ANIM_TOGGLE:
				{
					name: "Alt Animation Toggle",
					params: [
						{
							name: "Strumline",
							type: TStrumLine,
							defValue: 0
						},
						{
							name: "Enable",
							type: TBool,
							defValue: true
						}
					]
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
		super(-100, (step * 40) - 17, 100, 34, 'editors/charter/event-spr');
		this.step = step;
		this.events = events.getDefault([]);

		cursor = BUTTON;
	}

	public override function update(elapsed:Float) {
		super.update(elapsed);
		for(k=>i in icons) {
			i.follow(this, (k * 22) + 30 - (i.width / 2), (bHeight - i.height) / 2);
		}
	}

	private static function generateDefaultIcon(type:Int) {
			var spr = new FlxSprite().loadGraphic(Paths.image('editors/charter/event-icons'), true, 16, 16);
			spr.frame = spr.frames.frames[type+1];
			return spr;
	}

	public static function generateEventIcon(event:ChartEvent) {
		return switch(event.type) {
			default:
				generateDefaultIcon(event.type);
			case CAM_MOVEMENT:
				// custom icon for camera movement
				var state = cast(FlxG.state, Charter);
				if (event.params[0] != null && event.params[0] >= 0 && event.params[0] < state.strumLines.length) {
					// camera movement, use health icon
					var healthIcon = new HealthIcon('${state.strumLines.members[event.params[0]].strumLine.characters[0]}');
					healthIcon.setUnstretchedGraphicSize(32, 32, false);
					healthIcon;
				} else
					generateDefaultIcon(event.type);
		}
	}

	public override function onHovered() {
		super.onHovered();
		if (FlxG.mouse.justReleased)
			FlxG.state.openSubState(new CharterEventScreen(this));
	}

	public function refreshEventIcons() {
		while(icons.length > 0) {
			var i = icons.shift();
			members.remove(i);
			i.destroy();
		}

		for(event in events) {
			var spr = generateEventIcon(event);
			icons.push(spr);
			members.push(spr);
		}

		x = -(bWidth = 37 + (icons.length * 22));
	}
}

typedef EventDefineInfo = {
	var name:String;
	var params:Array<EventParamInfo>;
}
typedef EventInfo = {
	> EventDefineInfo,
	var paramValues:Array<Dynamic>;
}

typedef EventParamInfo = {
	var name:String;
	var type:EventParamType;
	var defValue:Dynamic;
}

enum EventParamType {
	TBool;
	TInt(?min:Int, ?max:Int, ?step:Float);
	TFloat(?min:Int, ?max:Int, ?step:Float, ?precision:Int);
	TString;
	TArrayOfString;
	TStrumLine;
}