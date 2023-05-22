package funkin.editors.charter;

import funkin.editors.charter.EventsData;

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
			add(new UIButton(10, 41 + (32 * k), eventName, function() {
				close();
				callback(eventName);
			}, w));

			lastIndex = k;
		}

		add(new UIButton(10, 51 + (32 * (lastIndex+1)), "Cancel", function() {
			close();
		}, w));

		windowSpr.bHeight = 61 + (32 * (lastIndex+2));
	}
}