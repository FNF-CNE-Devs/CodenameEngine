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
	
	public var noteTypeDropdown:UIDropDown;

	public var noteTypeNameBox:UITextBox;

	public var closeRemoveNoteCallback:Int->Void;

	public function new(data:ChartData) {
		super();
		this.data = data;
	}

	public override function create() {
		FlxG.sound.music.pause();
		Charter.instance.vocals.pause();

		function addLabelOn(ui:UISprite, text:String)
			add(new UIText(ui.x, ui.y - 24, 0, text));

		winTitle = 'Edit note types';
		winWidth = 420; winHeight = 69*4; // guys look, the funny numbers!

		super.create();

		noteTypeDropdown = new UIDropDown(windowSpr.x + 20, windowSpr.y + 60,200,32,PlayState.SONG.noteTypes);
		addLabelOn(noteTypeDropdown, "Note");
		add(noteTypeDropdown);

		addButton = new UIButton(windowSpr.x + 200 + 40, windowSpr.y + 60 + 32 + 16, "Add new note type", function() {
			noteTypeDropdown.visible = false;
			noteTypeDropdown.active = false;
			removeButton.visible = false;
			removeButton.active = false;

			addButton.field.text = 'Create note type';
			addButton.callback = function() {onSave(); close();}

			noteTypeNameBox = new UITextBox(windowSpr.x + 20, windowSpr.y + 60, '');
			add(noteTypeNameBox);
			
		}, 125);
		add(addButton);

		removeButton = new UIButton(windowSpr.x + 200 + 40, windowSpr.y + 60, "Remove note type", function() {
			onRemove();
			close();
		}, 125);
		add(removeButton);
		
		closeButton = new UIButton(windowSpr.x + windowSpr.bWidth - 20 - 125, windowSpr.y + windowSpr.bHeight - 16 - 32, "Cancel", function() {
			close();
		}, 125);
		add(closeButton);
		closeButton.x -= closeButton.bWidth;
	}

	public function onSave()
	{
		PlayState.SONG.noteTypes.push(noteTypeNameBox.label.text);
	}

	public function onRemove()
	{
		closeRemoveNoteCallback(noteTypeDropdown.index + 1);
		PlayState.SONG.noteTypes.remove(noteTypeDropdown.label.text);
	}

}