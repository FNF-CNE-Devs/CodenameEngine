package funkin.editors.charter;

import flixel.group.FlxGroup;

class CharterEventScreen extends UISubstateWindow {
	public var cam:FlxCamera;
	public var chartEvent:CharterEvent;

	public var iconsPanel:FlxGroup;

	public var paramsPanel:FlxGroup;
	public var paramsFields:Array<FlxBasic> = [];

	public function new(chartEvent:CharterEvent) {
		super();
		this.chartEvent = chartEvent;
	}

	public override function create() {
		winTitle = "Event group properties";
		winWidth = 960;

		super.create();

		FlxG.sound.music.pause(); // prevent the song from continuing

		iconsPanel = new FlxGroup();

		for(k=>e in chartEvent.events) {
			var butt = new UIButton(windowSpr.x + 1, windowSpr.y + 31 + (k*30), "", function() {
				changeTab(k);
			});
			butt.bWidth = butt.bHeight = 30;
			iconsPanel.add(butt);

			var icon = CharterEvent.generateEventIcon(e);
			icon.setPosition(butt.x + ((butt.bWidth - icon.width) / 2), butt.y + ((butt.bHeight - icon.height) / 2));
			iconsPanel.add(icon);
		}

		add(iconsPanel);

		paramsPanel = new FlxGroup();
		add(paramsPanel);
	}

	public var curEvent:Int = -1;

	public function changeTab(id:Int) {
		// TODO
		saveCurTab();
	}

	public function saveCurTab() {
		if (curEvent < 0) return;

		chartEvent.events[curEvent].params = [for(p in paramsFields) {
			if (p is UITextBox)
				cast(p, UITextBox).label.text;
			else
				null;
		}
		];
	}

	public override function update(elapsed:Float) {
		super.update(elapsed);

		if (controls.BACK)
			close();
	}
}