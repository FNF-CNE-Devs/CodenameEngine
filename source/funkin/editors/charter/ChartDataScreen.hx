package funkin.editors.charter;

import funkin.backend.chart.ChartData;
import flixel.math.FlxPoint;
import funkin.backend.chart.ChartData.ChartMetaData;

using StringTools;

class ChartDataScreen extends UISubstateWindow {
	public var data:ChartData;
	public var saveButton:UIButton;
	public var closeButton:UIButton;

	public var scrollSpeedStepper:UINumericStepper;
	public var stageBox:UITextBox;

	public function new(data:ChartData) {
		super();
		this.data = data;
		//trace(data);
	}

	public override function create() {
		FlxG.sound.music.pause();
		Charter.instance.vocals.pause();

		function addLabelOn(ui:UISprite, text:String)
			add(new UIText(ui.x, ui.y - 24, 0, text));

		winTitle = 'Editing chart data';
		winWidth = 420; winHeight = 69*4; // guys look, the funny numbers!

		super.create();

		scrollSpeedStepper = new UINumericStepper(windowSpr.x + 20, windowSpr.y + 60, data.scrollSpeed, 0.1, 2, 0, 100, 82);
		add(scrollSpeedStepper);
		addLabelOn(scrollSpeedStepper, "Scroll Speed");

		stageBox = new UITextBox(scrollSpeedStepper.x, scrollSpeedStepper.y + 60, PlayState.SONG.stage);
		add(stageBox);
		addLabelOn(stageBox, "Stage");

		saveButton = new UIButton(windowSpr.x + windowSpr.bWidth - 20 - 125, windowSpr.y + windowSpr.bHeight - 16 - 32, "Save & Close", function() {
			onSave();
			close();
		}, 125);
		add(saveButton);
		
		closeButton = new UIButton(saveButton.x - 20, saveButton.y, "Cancel", function() {
			//if (creatingStrumLine) onSave(null);
			close();
		}, 125);
		add(closeButton);
		closeButton.x -= closeButton.bWidth;
	}

	public function onSave()
	{
		PlayState.SONG.stage = stageBox.label.text;
		PlayState.SONG.scrollSpeed = scrollSpeedStepper.value;
		trace('chart speed: ${PlayState.SONG.scrollSpeed}, Stepper: ${scrollSpeedStepper.value}');
	}

}