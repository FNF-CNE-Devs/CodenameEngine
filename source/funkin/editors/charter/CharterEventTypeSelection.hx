package funkin.editors.charter;

import funkin.backend.chart.ChartData.ChartEventType;

class CharterEventTypeSelection extends UISubstateWindow {
	var callback:ChartEventType->Void;

	public function new(callback:ChartEventType->Void) {
		super();
		this.callback = callback;
	}

	public override function create() {
		winTitle = "Choose an event type...";
		super.create();
		var w:Int = winWidth - 20;
		var lastIndex:Int = 0;

		for(k=>eventType in ChartEventType.getChartEventTypes()) {
			var type = CharterEvent.getEventInfo(eventType);
			add(new UIButton(10, 41 + (32 * k), type.name, function() {
				close();
				callback(eventType);
			}, w));

			lastIndex = k;
		}

		add(new UIButton(10, 51 + (32 * (lastIndex+1)), "Cancel", function() {
			close();
		}, w));

		windowSpr.bHeight = 61 + (32 * (lastIndex+2));
	}
}