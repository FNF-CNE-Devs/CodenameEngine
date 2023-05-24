package funkin.editors.charter;

import funkin.backend.system.Conductor;
import funkin.game.HealthIcon;
import funkin.backend.chart.ChartData.ChartEvent;

class CharterEvent extends UISliceSprite {
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

	private static function generateDefaultIcon(name:String) {
		var path:String = Paths.image('editors/charter/event-icons/$name');
		if (!Assets.exists(path)) path = Paths.image('editors/charter/event-icons/Unknown');

		var spr = new FlxSprite().loadGraphic(path);
		return spr;
	}

	public static function generateEventIcon(event:ChartEvent) {
		return switch(event.name) {
			default:
				generateDefaultIcon(event.name);
			case "Camera Movement":
				// custom icon for camera movement
				var state = cast(FlxG.state, Charter);
				if (event.params[0] != null && event.params[0] >= 0 && event.params[0] < state.strumLines.length) {
					// camera movement, use health icon
					var healthIcon = new HealthIcon('${state.strumLines.members[event.params[0]].strumLine.characters[0]}');
					healthIcon.setUnstretchedGraphicSize(32, 32, false);
					healthIcon;
				} else
					generateDefaultIcon(event.name);
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