package funkin.editors.charter;

import funkin.backend.system.Conductor;
import flixel.group.FlxGroup;
import funkin.editors.charter.EventsData;
import flixel.util.FlxColor;

using StringTools;

class CharterEventScreen extends UISubstateWindow {
	public var cam:FlxCamera;
	public var chartEvent:CharterEvent;

	public var iconsPanel:FlxGroup;

	public var eventName:UIText;

	public var paramsPanel:FlxGroup;
	public var paramsFields:Array<FlxBasic> = [];
	
	public var addButton:UIButton;
	public var saveButton:UIButton;
	public var deleteButton:UIButton;

	public function new(chartEvent:CharterEvent) {
		super();
		this.chartEvent = chartEvent;
	}

	public override function create() {
		winTitle = "Event group properties";
		winWidth = 960;

		super.create();

		FlxG.sound.music.pause(); // prevent the song from continuing
		Charter.instance.vocals.pause();

		var bg:FlxSprite = new FlxSprite(windowSpr.x + 1, windowSpr.y + 31, Paths.image('editors/ui/scrollbar-bg'));
		bg.setGraphicSize(30, windowSpr.bHeight - 32);
		bg.updateHitbox();
		add(bg);

		iconsPanel = new FlxGroup();
		add(iconsPanel);

		addButton = new UIButton(windowSpr.x + 1, windowSpr.y + 31, "", function() {
			openSubState(new CharterEventTypeSelection(function(eventName) {
				chartEvent.events.push({
					time: Conductor.getTimeForStep(chartEvent.step),
					params: [],
					name: eventName
				});
				changeTab(chartEvent.events.length-1);
			}));
		});
		addButton.bWidth = addButton.bHeight = 30;
		add(addButton);

		var addButtonIcon = new FlxSprite(addButton.x, addButton.y, Paths.image('editors/charter/add-button'));
		addButtonIcon.x += (30 - addButtonIcon.width) / 2;
		addButtonIcon.y += (30 - addButtonIcon.height) / 2;
		add(addButtonIcon);

		paramsPanel = new FlxGroup();
		add(paramsPanel);

		saveButton = new UIButton(windowSpr.x + windowSpr.bWidth - 10, windowSpr.y + windowSpr.bHeight - 10, "Save & Close", function() {
			saveCurTab();
			chartEvent.refreshEventIcons();

			if (chartEvent.events.length <= 0) {
				var state = cast(FlxG.state, Charter);
				state.eventsGroup.remove(chartEvent, true);
			}
			close();
		});
		saveButton.x -= saveButton.bWidth;
		saveButton.y -= saveButton.bHeight;
		add(saveButton);

		deleteButton = new UIButton(saveButton.x - 10, saveButton.y, "Delete", function() {
			if (curEvent >= 0) {
				chartEvent.events.splice(curEvent, 1);
				changeTab(curEvent, false);
			}
		});
		deleteButton.x -= deleteButton.bWidth;
		add(deleteButton);

		eventName = new UIText(windowSpr.x + addButton.bWidth + 15, windowSpr.y + 41, 0, "", 24);
		add(eventName);

		changeTab(0);
	}

	public var curEvent:Int = -1;

	public function changeTab(id:Int, save:Bool = true) {
		if (save)
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
			eventName.text = curEvent.name;
			// add new elements
			var y:Float = eventName.y + eventName.height + 10;
			for(k=>param in EventsData.getEventParams(curEvent.name)) {
				function addLabel() {
					var label:UIText = new UIText(eventName.x, y, 0, param.name);
					y += label.height + 4;
					paramsPanel.add(label);
				};

				var value:Dynamic = CoolUtil.getDefault(curEvent.params[k], param.defValue);
				var lastAdded = switch(param.type) {
					case TString:
						addLabel();
						var textBox:UITextBox = new UITextBox(eventName.x, y, cast value);
						paramsPanel.add(textBox); paramsFields.push(textBox);
						textBox;
					case TBool:
						var checkbox = new UICheckbox(eventName.x, y, param.name, cast value);
						paramsPanel.add(checkbox); paramsFields.push(checkbox);
						checkbox;
					case TInt(min, max, step):
						addLabel();
						var numericStepper = new UINumericStepper(eventName.x, y, cast value, step.getDefault(1), 0, min, max);
						paramsPanel.add(numericStepper); paramsFields.push(numericStepper);
						numericStepper;
					case TFloat(min, max, step, precision):
						addLabel();
						var numericStepper = new UINumericStepper(eventName.x, y, cast value, step.getDefault(1), precision, min, max);
						paramsPanel.add(numericStepper); paramsFields.push(numericStepper);
						numericStepper;
					case TStrumLine:
						addLabel();
						var dropdown = new UIDropDown(eventName.x, y, 320, 32, [for(k=>s in cast(FlxG.state, Charter).strumLines.members) 'Strumline #${k+1} (${s.strumLine.characters[0]})'], cast value);
						paramsPanel.add(dropdown); paramsFields.push(dropdown);
						dropdown;
					case TColorWheel:
						addLabel();
						var colorWheel = new UIColorwheel(eventName.x, y, value is String ? FlxColor.fromString(value) : Std.int(value));
						paramsPanel.add(colorWheel); paramsFields.push(colorWheel);
						colorWheel;
					case TDropDown(options):
						addLabel();
						var dropdown = new UIDropDown(eventName.x, y, 320, 32, options, Std.int(Math.abs(options.indexOf(cast value))));
						paramsPanel.add(dropdown); paramsFields.push(dropdown);
						dropdown;
					default:
						paramsFields.push(null);
						null;
				}
				if (lastAdded is UISliceSprite)
					y += cast(lastAdded, UISliceSprite).bHeight + 4;
				else if (lastAdded is FlxSprite)
					y += cast(lastAdded, FlxSprite).height + 6;
			}
		} else {
			eventName.text = "No event";
			curEvent = -1;
		}

		refreshIcons();
	}

	public function refreshIcons() {
		while(iconsPanel.members.length > 0)
			iconsPanel.remove(iconsPanel.members[0], true).destroy();

		for(k=>e in chartEvent.events) {
			var butt = new UIButton(windowSpr.x + 1, windowSpr.y + 66 + (k*30), "", function() {
				changeTab(k);
			});
			butt.bWidth = butt.bHeight = 30;
			if (k == curEvent) {
				butt.framesOffset = 18;
				butt.active = false;
			}
			
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
				if (p is UIDropDown) {
					var dataParams = EventsData.getEventParams(chartEvent.events[curEvent].name);
					if (dataParams[paramsFields.indexOf(p)].type == TStrumLine) cast(p, UIDropDown).index;
					else cast(p, UIDropDown).label.text;
				}
				else if (p is UINumericStepper) {
					var stepper = cast(p, UINumericStepper);
					@:privateAccess stepper.__onChange(stepper.label.text);
					if (stepper.precision == 0) // int
						Std.int(stepper.value);
					else
						stepper.value;
				}
				else if (p is UITextBox)
					cast(p, UITextBox).label.text;
				else if (p is UICheckbox)
					cast(p, UICheckbox).checked;
				else if (p is UIColorwheel)
					cast(p, UIColorwheel).curColor;
				else
					null;
			}
		];
	}
}