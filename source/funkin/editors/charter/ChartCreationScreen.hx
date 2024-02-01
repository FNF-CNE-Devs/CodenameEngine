package funkin.editors.charter;

import funkin.game.HealthIcon;
import funkin.backend.chart.ChartData;
import haxe.io.Bytes;

typedef ChartCreationData = {
	var name:String;
	var chart:ChartData;
	var ?meta:Dynamic;
	var ?instBytes:Bytes;
	var ?voicesBytes:Bytes;
}

class ChartCreationScreen extends UISubstateWindow {
	private var onSave:Null<ChartCreationData> -> Void = null;

	public var difficultyNameTextBox:UITextBox;
	public var scrollSpeedTextBox:UINumericStepper;
	public var stageTextBox:UITextBox;
	public var strumLineList:UIButtonList<StrumLineButton>;

	public var saveButton:UIButton;
	public var closeButton:UIButton;

	public function new(?onSave:ChartCreationData->Void) {
		super();
		if (onSave != null) this.onSave = onSave;
	}

	public override function create() {
		winTitle = "Creating New Chart";

		winWidth = 652;
		winHeight = 600;

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

		stageTextBox = new UITextBox(difficultyNameTextBox.x + 200 + 26, difficultyNameTextBox.y, "Stage", 125);
		add(stageTextBox);
		addLabelOn(stageTextBox, "Stage");

		scrollSpeedTextBox = new UINumericStepper(stageTextBox.x + 125 + 26, difficultyNameTextBox.y, 1.0, 0.1, 2, null, null, 90);
		add(scrollSpeedTextBox);
		addLabelOn(scrollSpeedTextBox, "Scroll Speed");

		strumLineList = new UIButtonList<StrumLineButton>(difficultyNameTextBox.x, difficultyNameTextBox.y+difficultyNameTextBox.bHeight+36, 620, (552-179)-16, "", FlxPoint.get(620, 246), null, 6);
		strumLineList.frames = Paths.getFrames('editors/ui/inputbox');
		strumLineList.cameraSpacing = 0;
		strumLineList.addButton.callback = function() {
			strumLineList.add(new StrumLineButton(strumLineList.buttons.length, {
				characters: ["dad"],
				type: 0,
				notes: null,
				position: "DAD",
				strumPos: [0, 50],
				strumLinePos: 0.25,
				scrollSpeed: 1,
			}, strumLineList));
		}
		strumLineList.add(new StrumLineButton(0, {
			characters: ["dad"],
			type: 0,
			notes: null,
			position: "DAD",
			strumPos: [0, 50],
			strumLinePos: 0.25,
			scrollSpeed: 1,
		}, strumLineList));
		strumLineList.add(new StrumLineButton(1, {
			characters: ["bf"],
			type: 1,
			notes: null,
			position: "BOYFRIEND",
			strumPos: [0, 50],
			strumLinePos: 0.75,
			scrollSpeed: 1,
		}, strumLineList));
		strumLineList.add(new StrumLineButton(1, {
			characters: ["gf"],
			type: 2,
			notes: null,
			position: "GIRLFRIEND",
			strumPos: [0, 50],
			strumLinePos: 0.50,
			scrollSpeed: 1,
			visible: false,
		}, strumLineList));
		add(strumLineList);
		addLabelOn(strumLineList, "Strumlines");

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
				characters: [for (charb in strline.charactersList.buttons.members) charb.textBox.label.text],
				type: strline.typeDropdown.index,
				notes: [],
				position: strline.stagePositionDropdown.label.text,
				visible: strline.visibleCheckbox.checked,
				strumPos: [0, strline.hudYStepper.value],
				strumLinePos: strline.hudXStepper.value,
				strumScale: strline.hudScaleStepper.value,
				scrollSpeed: strline.usesChartscrollSpeed.checked ? strline.scrollSpeedStepper.value : null
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
		});
	}
}

class StrumLineButton extends UIButton {
	public var idText:UIText;

	public var charactersList:UIButtonList<CompactCharacterButton>;
	public var typeDropdown:UIDropDown;
	public var stagePositionDropdown:UIDropDown;
	public var hudScaleStepper:UINumericStepper;
	public var hudXStepper:UINumericStepper;
	public var hudYStepper:UINumericStepper;
	public var visibleCheckbox:UICheckbox;
	public var scrollSpeedStepper:UINumericStepper;
	public var usesChartscrollSpeed:UICheckbox;

	public var deleteButton:UIButton;
	public var deleteIcon:FlxSprite;

	public var labels:Map<UISprite, UIText> = [];
	public var XYComma:UIText;

	public function new(id:Int, strumLine:ChartStrumLine, parent:UIButtonList<StrumLineButton>) {
		super(0, 0, '', function () {}, 620, 246);

		autoAlpha = false; frames = Paths.getFrames('editors/ui/inputbox');

		function addLabelOn(ui:UISprite, text:String, ?size:Int):UIText {
			var uiText:UIText = new UIText(ui.x, ui.y - 24, 0, text, size);
			members.push(uiText); labels.set(ui, uiText);
			return uiText;
		}

		charactersList = new UIButtonList<CompactCharacterButton>(16, 8+26, 210, 160, "", FlxPoint.get(200, 40), null, 5);
		charactersList.frames = Paths.getFrames('editors/ui/inputbox');
		charactersList.cameraSpacing = 0;
		charactersList.add(new CompactCharacterButton(strumLine.characters[0], [], charactersList));
		members.push(charactersList);
		idText = addLabelOn(charactersList, 'Strumline - #$id');

		typeDropdown = new UIDropDown(charactersList.x + charactersList.bWidth + 16, 8+26, 200, 32, ["OPPONENT", "PLAYER", "ADDITIONAL"], strumLine.type);
		members.push(typeDropdown);
		addLabelOn(typeDropdown, "Type");

		var stagePositionI = strumLine.position == null ? strumLine.type : ["DAD", "BOYFRIEND", "GIRLFRIEND"].indexOf(strumLine.position.toUpperCase());

		stagePositionDropdown = new UIDropDown(typeDropdown.x + 200 - 32 + 26, typeDropdown.y, 200, 32, ["DAD", "BOYFRIEND", "GIRLFRIEND"], stagePositionI);
		members.push(stagePositionDropdown);
		addLabelOn(stagePositionDropdown, "Stage Position");

		hudScaleStepper = new UINumericStepper(typeDropdown.x, typeDropdown.y + 64, strumLine.strumScale == null ? 1 : strumLine.strumScale, 0.001, 2, null, null, 74);
		members.push(hudScaleStepper);
		addLabelOn(hudScaleStepper, "Scale");

		var strOffset:Float = strumLine.strumLinePos == null ? (strumLine.type == 1 ? 0.75 : 0.25) : strumLine.strumLinePos;

		var startingPos:FlxPoint = strumLine.strumLinePos == null ?
			FlxPoint.get(strOffset, 50) :
			FlxPoint.get(strOffset, strumLine.strumPos[1]);

		hudXStepper = new UINumericStepper(hudScaleStepper.x + 80 - 32 + 26, hudScaleStepper.y, startingPos.x, 0.01, 2, 0, 2, 84);
		members.push(hudXStepper);
		addLabelOn(hudXStepper, "Hud Position (X,Y)");

		members.push(XYComma = new UIText(hudXStepper.x + 84 - 32 + 0, hudXStepper.y + 9, 0, ",", 22));

		hudYStepper = new UINumericStepper(hudXStepper.x + 84 - 32 + 26, hudXStepper.y, startingPos.y, 0.001, 2, null, null, 84);
		members.push(hudYStepper);

		visibleCheckbox = new UICheckbox(hudYStepper.x + hudYStepper.bWidth + 42, hudYStepper.y + 9, "Visible?", strumLine.visible == null ? true : strumLine.visible);
		members.push(visibleCheckbox);

		scrollSpeedStepper = new UINumericStepper(typeDropdown.x, typeDropdown.y + 128, strumLine.scrollSpeed, 0.1, 2, 0, 10, 82);
		if(strumLine.scrollSpeed == null)
		{
			scrollSpeedStepper.selectable = false;
		} else {
			scrollSpeedStepper.selectable = true;
		}
		members.push(scrollSpeedStepper);
		addLabelOn(scrollSpeedStepper, "Scroll Speed");

		usesChartscrollSpeed = new UICheckbox(scrollSpeedStepper.x + 104, typeDropdown.y + 135, "Uses charts scroll speed?", strumLine.scrollSpeed == null);
		usesChartscrollSpeed.onChecked = function(b) {
			if(b)
			{
				scrollSpeedStepper.value = PlayState.SONG.scrollSpeed;
				scrollSpeedStepper.selectable = false;
			} else {
				scrollSpeedStepper.selectable = true;
			}
		}
		members.push(usesChartscrollSpeed);

		deleteButton = new UIButton(16, 246-32-11, "", function () {
			parent.remove(this);
		}, 620-32);
		deleteButton.color = 0xFFFF0000;
		deleteButton.autoAlpha = false;
		members.push(deleteButton);

		deleteIcon = new FlxSprite(deleteButton.x + ((deleteButton.bWidth/2)-(15/2)), deleteButton.y + ((deleteButton.bHeight/2)-(16/2))).loadGraphic(Paths.image('editors/delete-button'));
		deleteIcon.antialiasing = false;
		members.push(deleteIcon);
	}

	public override function update(elapsed:Float) {
		super.update(elapsed);

		charactersList.follow(this, 16, 8+26);
		typeDropdown.follow(this, charactersList.x + charactersList.bWidth + 16, 8+26);
		stagePositionDropdown.follow(this, typeDropdown.x + 200 - 32 + 26, 8+26);
		hudScaleStepper.follow(this, typeDropdown.x, 8+26 + 64);
		hudXStepper.follow(this, hudScaleStepper.x + 80 - 32 + 26, 8+26 + 64);
		hudYStepper.follow(this, hudXStepper.x + 84 - 32 + 26, 8+26 + 64);
		visibleCheckbox.follow(this, hudYStepper.x + hudYStepper.bWidth + 42, 8+26 + 64 + 9);
		scrollSpeedStepper.follow(this, typeDropdown.x, 8+26 + 128);
		usesChartscrollSpeed.follow(this, scrollSpeedStepper.x + 104, 8+26 + 135);

		deleteButton.follow(this, 16, 246-32-11);
		deleteIcon.follow(this, 16 + ((deleteButton.bWidth/2)-(15/2)), (246-32-11) + ((deleteButton.bHeight/2)-(16/2)));

		XYComma.follow(hudXStepper, 84 - 32, 9);
		for (ui => text in labels)
			text.follow(ui, 0, -24);
	}
}

class CompactCharacterButton extends UIButton {
	public var charIcon:HealthIcon;
	public var textBox:UIAutoCompleteTextBox;
	public var deleteButton:UIButton;
	public var deleteIcon:FlxSprite;

	public function new(char:String, charsList:Array<String>, parent:UIButtonList<CompactCharacterButton>) {
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