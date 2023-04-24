package funkin.editors.charter;

import flixel.group.FlxGroup;

class CharterEventScreen extends UISubstateWindow {
	public var cam:FlxCamera;
	public var chartEvent:CharterEvent;

	public var iconsPanel:FlxGroup;

	public var eventName:UIText;

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
		add(iconsPanel);

		paramsPanel = new FlxGroup();
		add(paramsPanel);

		eventName = new UIText(windowSpr.x + 40, windowSpr.y + 41, 0, "", 24);
		add(eventName);

		changeTab(0);
	}

	public var curEvent:Int = -1;

	public function changeTab(id:Int) {
		saveCurTab();
		

		// destroy old elements
		paramsFields = [];
		for(e in paramsPanel) {
			e.destroy();
			paramsPanel.remove(e);
		}

		if (id >= 0 && id < chartEvent.events.length) {
			curEvent = id;
			var curEvent = chartEvent.events[curEvent];
			var data = CharterEvent.getEventInfo(curEvent.type);
			eventName.text = data.name;
			// add new elements
			var y:Float = eventName.y + eventName.height + 10;
			for(k=>param in data.params) {
				switch(param.type) {
					case TString:
						var label:UIText = new UIText(eventName.x, y, 0, param.name);
						y += label.height + 4;
						paramsPanel.add(label);

						var textBox:UITextBox = new UITextBox(eventName.x, y, cast curEvent.params[k]);
						y += textBox.height + 10;
						paramsPanel.add(textBox);
						paramsFields.push(textBox);
					case TBool:
						var checkbox = new UICheckbox(eventName.x, y, param.name, cast curEvent.params[k]);
						y += checkbox.height + 10;
						paramsPanel.add(checkbox);
						paramsFields.push(checkbox);
					case TInt(min, max, step):
						var label:UIText = new UIText(eventName.x, y, 0, param.name);
						y += label.height + 4;
						paramsPanel.add(label);

						var numericStepper = new UINumericStepper(eventName.x, y, cast curEvent.params[k], step.getDefault(1), 0, min, max);
						y += numericStepper.height + 10;
						paramsPanel.add(numericStepper);
						paramsFields.push(numericStepper);
					case TFloat(min, max, step, precision):
						var label:UIText = new UIText(eventName.x, y, 0, param.name);
						y += label.height + 4;
						paramsPanel.add(label);

						var numericStepper = new UINumericStepper(eventName.x, y, cast curEvent.params[k], step.getDefault(1), precision, min, max);
						y += numericStepper.height + 10;
						paramsPanel.add(numericStepper);
						paramsFields.push(numericStepper);
					case TStrumLine:
						var dropdown = new UIDropDown(eventName.x, y, 320, 32, [for(k=>s in cast(FlxG.state, Charter).strumLines.members) 'Strumline #${k+1} (${s.strumLine.characters[0]})'], cast curEvent.params[k]);
						y += dropdown.height + 10;
						paramsPanel.add(dropdown);
						paramsFields.push(dropdown);
					default:
						// none
						paramsFields.push(null);
				}
			}
		} else
			curEvent = -1;

		refreshIcons();
	}

	public function refreshIcons() {
		while(iconsPanel.members.length > 0)
			iconsPanel.remove(iconsPanel.members[0], true).destroy();

		for(k=>e in chartEvent.events) {
			var butt = new UIButton(windowSpr.x + 1, windowSpr.y + 31 + (k*30), "", function() {
				changeTab(k);
			});
			butt.bWidth = butt.bHeight = 30;
			butt.visible = (k != curEvent);
			iconsPanel.add(butt);

			var icon = CharterEvent.generateEventIcon(e);
			icon.setPosition(butt.x + ((butt.bWidth - icon.width) / 2), butt.y + ((butt.bHeight - icon.height) / 2));
			iconsPanel.add(icon);
		}
	}

	public function saveCurTab() {
		if (curEvent < 0) return;

		chartEvent.events[curEvent].params = [
			for(p in paramsFields) {
				if (p is UIDropDown)
					cast(p, UIDropDown).index;
				else if (p is UINumericStepper) {
					var stepper = cast(p, UINumericStepper);
					// int
					if (stepper.precision == 0)
						Std.int(stepper.value);
					else
						stepper.value;
				}
				else if (p is UITextBox)
					cast(p, UITextBox).label.text;
				else if (p is UICheckbox)
					cast(p, UICheckbox).checked;
				else
					null;
			}
		];
	}

	public override function update(elapsed:Float) {
		super.update(elapsed);

		if (FlxG.keys.justPressed.ESCAPE || controls.BACK)
			close();
	}
}