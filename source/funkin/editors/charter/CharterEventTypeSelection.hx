package funkin.editors.charter;

import funkin.backend.chart.EventsData;

class CharterEventTypeSelection extends UISubstateWindow {
	var callback:String->Void;

	public function new(callback:String->Void) {
		super();
		this.callback = callback;
	}

	public override function create() {
		winTitle = "Choose an event type...";
		super.create();
		var w:Int = winWidth - 20;
		var lastIndex:Int = 0;

		for(k=>eventName in EventsData.eventsList) {
			var button = new UIButton(10, 41 + (32 * k), eventName, function() {
				close();
				callback(eventName);
			}, w);
			add(button);

			var icon = CharterEvent.generateEventIcon({
				name: eventName,
				time: 0,
				params: []
			});
			icon.setGraphicSize(20, 20); // Std.int(button.bHeight - 12)
			icon.updateHitbox();
			icon.x = button.x + 8;
			icon.y = button.y + Math.abs(button.bHeight - icon.height) / 2;
			add(icon);

			lastIndex = k;
		}

		add(new UIButton(10, 51 + (32 * (lastIndex+1)), "Cancel", function() {
			close();
		}, w));

		windowSpr.bHeight = 61 + (32 * (lastIndex+2));
	}
}