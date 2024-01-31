package funkin.editors.charter;

import funkin.game.HealthIcon;
import funkin.backend.chart.ChartData;
import haxe.io.Bytes;

typedef ChartCreationData = {
	var name:String;
	var chart:ChartData;
	var meta:Dynamic;
	var ?instBytes:Bytes;
	var ?voicesBytes:Bytes;
}

class ChartCreationScreen extends UISubstateWindow {
	private var onSave:Null<ChartCreationData> -> Void = null;

	public var difficultyNameTextBox:UITextBox;
	public var scrollSpeedTextBox:UINumericStepper;
	public var stageTextBox:UITextBox;
	public var strumLineList:UIButtonList<StrumLineButton>;

	public var instExplorer:UIFileExplorer;
	public var voicesExplorer:UIFileExplorer;
	public var bpmStepper:UINumericStepper;
	public var beatsPerMeasureStepper:UINumericStepper;
	public var stepsPerBeatStepper:UINumericStepper;

	public var saveButton:UIButton;
	public var closeButton:UIButton;

	public function new(?onSave:ChartCreationData->Void) {
		super();
		if (onSave != null) this.onSave = onSave;
	}

	public override function create() {
		winTitle = "Creating New Chart";

		winWidth = 948 - 32 + 40;
		winHeight = 520;

		super.create();

		function addLabelOn(ui:UISprite, text:String):UIText {
			var text:UIText = new UIText(ui.x, ui.y - 24, 0, text);
			ui.members.push(text);
			return text;
		}

		var chartTitle:UIText;
		add(chartTitle = new UIText(windowSpr.x + 20, windowSpr.y + 30 + 16, 0, "Chart Info", 28));

		difficultyNameTextBox = new UITextBox(chartTitle.x, chartTitle.y + chartTitle.height + 36, "Difficulty Name", 200);
		add(difficultyNameTextBox);
		addLabelOn(difficultyNameTextBox, "Difficulty Name");

		scrollSpeedTextBox = new UINumericStepper(difficultyNameTextBox.x + 200 + 26, difficultyNameTextBox.y, 1.0, 0.1, 2, null, null, 90);
		add(scrollSpeedTextBox);
		addLabelOn(scrollSpeedTextBox, "Scroll Speed");

		stageTextBox = new UITextBox(chartTitle.x, scrollSpeedTextBox.y + 32 + 36, "Stage", 125);
		add(stageTextBox);
		addLabelOn(stageTextBox, "Stage");

		strumLineList = new UIButtonList<StrumLineButton>(scrollSpeedTextBox.x + 150 + 26, scrollSpeedTextBox.y, 520, 350, "", FlxPoint.get(510, 150), null, 5);
		strumLineList.frames = Paths.getFrames('editors/ui/inputbox');
		strumLineList.cameraSpacing = 0;
		strumLineList.add(new StrumLineButton(0, "dad", 0, true));
		strumLineList.add(new StrumLineButton(1, "bf", 1, true));
		strumLineList.add(new StrumLineButton(2, "gf", 2, false));
		add(strumLineList);
		addLabelOn(strumLineList, "Strumlines");

		var songTitle:UIText;
		add(songTitle = new UIText(stageTextBox.x, stageTextBox.y + 32 + 26, 0, "Specific Song (OPTIONAL)", 28));

		instExplorer = new UIFileExplorer(songTitle.x, songTitle.y + songTitle.height + 36, 174, null, Paths.SOUND_EXT, function (res) {
			var audioPlayer:UIAudioPlayer = new UIAudioPlayer(instExplorer.x + 8, instExplorer.y + 8, res);
			instExplorer.members.push(audioPlayer);
			instExplorer.uiElement = audioPlayer;
		});
		add(instExplorer);
		addLabelOn(instExplorer, "Inst Audio File");

		voicesExplorer = new UIFileExplorer(instExplorer.x + 174 + 26, instExplorer.y, 174, null, Paths.SOUND_EXT, function (res) {
			var audioPlayer:UIAudioPlayer = new UIAudioPlayer(voicesExplorer.x + 8, voicesExplorer.y + 8, res);
			voicesExplorer.members.push(audioPlayer);
			voicesExplorer.uiElement = audioPlayer;
		});
		add(voicesExplorer);
		addLabelOn(voicesExplorer, "Voices Audio File");

		bpmStepper = new UINumericStepper(instExplorer.x, instExplorer.y + 58 + 36, 100, 1, 2, 1, null, 90);
		add(bpmStepper);
		addLabelOn(bpmStepper, "BPM");

		beatsPerMeasureStepper = new UINumericStepper(bpmStepper.x + 60 + 26, bpmStepper.y, 4, 1, 0, 1, null, 54);
		add(beatsPerMeasureStepper);
		addLabelOn(beatsPerMeasureStepper, "Time Signature");

		add(new UIText(beatsPerMeasureStepper.x + 30, beatsPerMeasureStepper.y + 3, 0, "/", 22));

		stepsPerBeatStepper = new UINumericStepper(beatsPerMeasureStepper.x + 30 + 24, beatsPerMeasureStepper.y, 4, 1, 0, 1, null, 54);
		add(stepsPerBeatStepper);

		saveButton = new UIButton(windowSpr.x + windowSpr.bWidth - 20 - 125, windowSpr.y + windowSpr.bHeight - 16 - 32, "Create Chart", function() {
			createChart();
			close();
		}, 125);
		add(saveButton);

		closeButton = new UIButton(saveButton.x - 20 - saveButton.bWidth, saveButton.y, "Cancel", function() {
			close();
		}, 125);
		add(closeButton);
		closeButton.color = 0xFFFF0000;
	}

	function createChart() {
		var strlines = [];
		for (strline in strumLineList.buttons.members) {
			strlines.push({
				characters: [for (charb in strline.characterList.buttons.members) charb.textBox.label.text],
				type: strline.typeDropDown.index,
				notes: [],
				position: null,
				visible: strline.visibleCheckBox.checked,
				strumPos: [0, strline.positionYStepper.value],
				strumLinePos: strline.positionXStepper.value,
			});
		}
		var chartData:ChartData = {
			codenameChart: true,
			strumLines: strlines,
			stage: stageTextBox.label.text,
			scrollSpeed: scrollSpeedTextBox.value,
			events: [],
			noteTypes: [],
			meta: null
		}

		if (onSave != null) onSave({
			name: difficultyNameTextBox.label.text,
			chart: chartData,
			meta: {
				bpm: bpmStepper.value,
				beatsPerMeasure: beatsPerMeasureStepper.value,
				stepsPerBeat: stepsPerBeatStepper.value
			},
			instBytes: instExplorer.file,
			voicesBytes: voicesExplorer.file
		});
	}
}

class StrumLineButton extends UIButton {
	public var numberText:UIText;
	public var positionXStepper:UINumericStepper;
	public var positionXStepperText:UIText;
	public var positionYStepper:UINumericStepper;
	public var positionYStepperText:UIText;
	public var typeDropDownText:UIText;
	public var typeDropDown:UIDropDown;
	public var visibleCheckBoxText:UIText;
	public var visibleCheckBox:UICheckbox;
	public var characterList:UIButtonList<CompressedCharacterButton>;
	public function new(id:Int, char:String, type:Int, visible:Bool) {
		super(0, 0, '', function () {}, 510, 150);
		numberText = new UIText(5, 5, 0, 'Strumline #$id');
		members.push(numberText);

		positionXStepperText = new UIText(numberText.x, numberText.y + 26, 0, "X (ratio)");
		members.push(positionXStepperText);

		positionXStepper = new UINumericStepper(positionXStepperText.x, positionXStepperText.y + 24, 1.0, 0.1, 2, null, null, 90);
		members.push(positionXStepper);

		positionYStepperText = new UIText(positionXStepper.x + 60 + 26, positionXStepper.y, 0, "Y");
		members.push(positionYStepperText);

		positionYStepper = new UINumericStepper(positionYStepperText.x, positionYStepperText.y + 24, 1.0, 0.1, 2, null, null, 90);
		members.push(positionYStepper);

		visibleCheckBoxText = new UIText(positionXStepper.x + 90 + 26, positionXStepper.y, 0, "Visible?");
		members.push(visibleCheckBoxText);

		visibleCheckBox = new UICheckbox(visibleCheckBoxText.x, positionYStepperText.y + 24, "Visible", visible);
		members.push(visibleCheckBox);

		typeDropDownText = new UIText(positionXStepper.x, positionXStepper.y + 32 + 36, 0, "Type");
		members.push(typeDropDownText);

		typeDropDown = new UIDropDown(typeDropDownText.x, typeDropDownText.y + 24, 165, 32, ["OPPONENT", "PLAYER", "ADDITIONAL"], type);
		members.push(typeDropDown);

		characterList = new UIButtonList<CompressedCharacterButton>(numberText.x + 265 + 26, numberText.y, 210, 140, "", FlxPoint.get(200, 40), null, 5);
		characterList.frames = Paths.getFrames('editors/ui/inputbox');
		characterList.cameraSpacing = 0;
		characterList.add(new CompressedCharacterButton(char, [], characterList));
		members.push(characterList);
	}
	public override function update(elapsed) {
		numberText.follow(this, 5, 5);
		positionXStepperText.follow(numberText, 0, 26);
		positionXStepper.follow(positionXStepperText, 0, 24);
		positionYStepperText.follow(positionXStepperText, 65 + 26, 0);
		positionYStepper.follow(positionYStepperText, 0, 24);
		visibleCheckBoxText.follow(positionYStepperText, 65 + 26, 0);
		visibleCheckBox.follow(visibleCheckBoxText, 0, 24);
		typeDropDownText.follow(positionXStepper, 0, 36);
		typeDropDown.follow(typeDropDownText, 0, 24);
		characterList.follow(numberText, 265 + 26, 0);
		super.update(elapsed);
	}
}

class CompressedCharacterButton extends UIButton {
	public var charIcon:HealthIcon;
	public var textBox:UIAutoCompleteTextBox;
	public var deleteButton:UIButton;
	public var deleteIcon:FlxSprite;

	public function new(char:String, charsList:Array<String>, parent:UIButtonList<CompressedCharacterButton>) {
		super(0, 0, "", null, 200, 40);
		autoAlpha = false;

		charIcon = new HealthIcon(funkin.game.Character.getIconFromCharName(char));
		charIcon.scale.set(0.2, 0.2);
		charIcon.updateHitbox();
		charIcon.setPosition(10, bHeight/2 - charIcon.height / 2);
		charIcon.scrollFactor.set(1,1);

		members.push(charIcon);

		members.push(textBox = new UIAutoCompleteTextBox(charIcon.x + charIcon.width + 16, bHeight/2 - (32/2), char, 115));
		textBox.suggestItems = charsList;
		textBox.antialiasing = true;
		textBox.onChange = function(char:String) {
			char = funkin.game.Character.getIconFromCharName(char);
			var image = Paths.image("icons/" + char);
			if(!Assets.exists(image))
				image = Paths.image("icons/face");
			charIcon.loadGraphic(image, true, 150, 150);
			charIcon.updateHitbox();
		}

		deleteButton = new UIButton(textBox.x + 115 + 16, bHeight/2 - (32/2), "", function () {
			parent.remove(this);
		}, 32);
		deleteButton.color = 0xFFFF0000;
		deleteButton.autoAlpha = false;
		members.push(deleteButton);

		deleteIcon = new FlxSprite(deleteButton.x + (15/2), deleteButton.y + 8).loadGraphic(Paths.image('editors/delete-button'));
		deleteIcon.antialiasing = false;
		members.push(deleteIcon);
	}

	override function update(elapsed) {
		charIcon.follow(this, 6, bHeight / 2 - charIcon.height / 2);
		textBox.follow(charIcon, charIcon.width + 6, 0);
		deleteButton.follow(textBox, 115 + 6, 0);
		deleteIcon.follow(deleteButton, 15 / 2, 8);

		deleteButton.selectable = selectable;
		deleteButton.shouldPress = shouldPress;

		super.update(elapsed);
	}
}