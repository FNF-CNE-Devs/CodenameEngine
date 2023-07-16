package funkin.editors.charter;

import funkin.backend.chart.ChartData;
import flixel.math.FlxPoint;
import funkin.backend.chart.ChartData.ChartMetaData;

using StringTools;

class NoteTypeScreen extends UISubstateWindow {
	public var data:ChartData;
	public var addButton:UIButton;
	public var closeButton:UIButton;
	public var removeButton:UIButton;

	public var scrollSpeedStepper:UINumericStepper;
	public var stageBox:UITextBox;

	public function new(data:ChartData) {
		super();
		this.data = data;
	}

	public override function create() {
		FlxG.sound.music.pause();
		Charter.instance.vocals.pause();

		function addLabelOn(ui:UISprite, text:String)
			add(new UIText(ui.x, ui.y - 24, 0, text));

		winTitle = 'Edit custom notes';
		winWidth = 420; winHeight = 69*4; // guys look, the funny numbers!

		super.create();

		stageBox = new UITextBox(windowSpr.x + 20, windowSpr.y + 60, '');
		add(stageBox);
		addLabelOn(stageBox, "Note");

		addButton = new UIButton(windowSpr.x + windowSpr.bWidth - 20 - 125, windowSpr.y + windowSpr.bHeight - 16 - 32, "Add & Close", function() {
			onSave();
			close();
		}, 125);
		add(addButton);

		removeButton = new UIButton(windowSpr.x + windowSpr.bWidth - 20 - 125, windowSpr.y + windowSpr.bHeight - 16 - 32 - 32 - 16, "Remove & Close", function() {
			onRemove();
			close();
		}, 125);
		add(removeButton);
		
		closeButton = new UIButton(addButton.x - 20, addButton.y, "Cancel", function() {
			close();
		}, 125);
		add(closeButton);
		closeButton.x -= closeButton.bWidth;
	}

	public function onSave()
	{
		PlayState.SONG.noteTypes.push(stageBox.label.text);
	}

	public function onRemove()
	{
		PlayState.SONG.noteTypes.remove(stageBox.label.text);
	}

}