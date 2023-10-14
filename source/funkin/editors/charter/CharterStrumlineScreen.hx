package funkin.editors.charter;

import flixel.math.FlxPoint;
import funkin.game.Note;
import funkin.game.Character;
import funkin.game.HealthIcon;
import funkin.backend.chart.ChartData.ChartStrumLine;

class CharterStrumlineScreen extends UISubstateWindow {
	public var strumLineID:Int = -1;
	public var strumLine:ChartStrumLine;

	public var charactersList:UIButtonList<CharacterButton>;
	public var typeDropdown:UIDropDown;
	public var stagePositionDropdown:UIDropDown;
	public var hudScaleStepper:UINumericStepper;
	public var hudXStepper:UINumericStepper;
	public var hudYStepper:UINumericStepper;
	public var scrollSpeedStepper:UINumericStepper;
	public var usesChartscrollSpeed:UICheckbox;

	public var characterIcons:Array<HealthIcon> = [];

	public var saveButton:UIButton;
	public var closeButton:UIButton;

	private var onSave:ChartStrumLine -> Void = null;

	public function new(strumLineID:Int, strumLine:ChartStrumLine, ?onSave:ChartStrumLine->Void) {
		super();
		this.strumLineID = strumLineID;
		this.strumLine = strumLine;
		if (onSave != null) this.onSave = onSave;
	}

	public override function create() {
		var creatingStrumLine:Bool = strumLine == null;

		if (creatingStrumLine)
			strumLine = {
				characters: ["dad"],
				type: OPPONENT,
				notes: [],
				position: "dad",
				visible: true
			};

		winTitle = creatingStrumLine ? 'Creating strumline #$strumLineID' : 'Editing strumline #$strumLineID properties';
		winWidth = 690; winHeight = 390;

		FlxG.sound.music.pause();
		Charter.instance.vocals.pause();

		super.create();

		function addLabelOn(ui:UISprite, text:String)
			add(new UIText(ui.x, ui.y - 24, 0, text));

		var title:UIText;
		add(title = new UIText(windowSpr.x + 20, windowSpr.y + 30 + 16, 0, creatingStrumLine ? "Create New Strumline" : "Edit Strumline Properties", 28));

		var charFileList = Character.getList(true);
		if (charFileList.length == 0) charFileList = Character.getList(false);
		
		charactersList = new UIButtonList<CharacterButton>(15, title.y + title.height + 36, 250, 259, "", FlxPoint.get(250, 54), null, 0);
		charactersList.addButton.callback = () -> charactersList.add(new CharacterButton(0, 0, "New Char", charFileList, charactersList));
		charactersList.cameraSpacing = 0;
		for (i in strumLine.characters)
			charactersList.add(new CharacterButton(0, 0, i, charFileList, charactersList));
		add(charactersList);
		addLabelOn(charactersList, "Characters");

		charactersList.frames = Paths.getFrames('editors/ui/inputbox');

		typeDropdown = new UIDropDown(charactersList.x + charactersList.bWidth + 16, charactersList.y, 200, 32, ["OPPONENT", "PLAYER", "ADDITIONAL"], strumLine.type);
		add(typeDropdown);
		addLabelOn(typeDropdown, "Type");

		usesChartscrollSpeed = new UICheckbox(typeDropdown.x + 104, typeDropdown.y + 135, "Uses charts scroll speed?", strumLine.scrollSpeed == null);
		usesChartscrollSpeed.onChecked = function(b) {
			if(b)
			{
				scrollSpeedStepper.value = PlayState.SONG.scrollSpeed;
				scrollSpeedStepper.selectable = false;
			} else {
				scrollSpeedStepper.selectable = true;
			}
		}
		add(usesChartscrollSpeed);

		scrollSpeedStepper = new UINumericStepper(typeDropdown.x, typeDropdown.y + 128, usesChartscrollSpeed.checked ? PlayState.SONG.scrollSpeed : strumLine.scrollSpeed, 0.1, 2, 0, 10, 82);
		if(usesChartscrollSpeed.checked)
		{
			scrollSpeedStepper.selectable = false;
		} else {
			scrollSpeedStepper.selectable = true;
		}
		add(scrollSpeedStepper);
		addLabelOn(scrollSpeedStepper, "Scroll Speed");

		var stagePositionI = strumLine.position == null ? strumLine.type : ["DAD", "BOYFRIEND", "GIRLFRIEND"].indexOf(strumLine.position.toUpperCase());

		stagePositionDropdown = new UIDropDown(typeDropdown.x + 200 - 32 + 26, typeDropdown.y, 200, 32, ["DAD", "BOYFRIEND", "GIRLFRIEND"], stagePositionI);
		add(stagePositionDropdown);
		addLabelOn(stagePositionDropdown, "Stage Position");

		hudScaleStepper = new UINumericStepper(typeDropdown.x, typeDropdown.y + 64, strumLine.strumScale == null ? 1 : strumLine.strumScale, 0.001, 2, null, null, 74);
		add(hudScaleStepper);
		addLabelOn(hudScaleStepper, "Scale");

		var strOffset:Float = strumLine.strumLinePos == null ? (strumLine.type == 1 ? 0.75 : 0.25) : strumLine.strumLinePos;

		var startingPos:FlxPoint = strumLine.strumPos == null ?
			FlxPoint.get((FlxG.width * strOffset) - ((Note.swagWidth * (strumLine.strumScale == null ? 1 : strumLine.strumScale)) * 2), 50) :
			FlxPoint.get(strumLine.strumPos[0], strumLine.strumPos[1]);

		hudXStepper = new UINumericStepper(hudScaleStepper.x + 80 - 32 + 26, hudScaleStepper.y, startingPos.x, 0.001, 2, null, null, 84);
		add(hudXStepper);
		addLabelOn(hudXStepper, "Hud Position (X,Y)");

		add(new UIText(hudXStepper.x + 84 - 32 + 0, hudXStepper.y + 9, 0, ",", 22));

		hudYStepper = new UINumericStepper(hudXStepper.x + 84 - 32 + 26, hudXStepper.y, startingPos.y, 0.001, 2, null, null, 84);
		add(hudYStepper);

		saveButton = new UIButton(windowSpr.x + windowSpr.bWidth - 20 - 125, windowSpr.y + windowSpr.bHeight - 16 - 32, "Save & Close", function() {
			saveStrumline();
			close();
		}, 125);
		add(saveButton);

		closeButton = new UIButton(saveButton.x - 20 - saveButton.bWidth, saveButton.y, creatingStrumLine ? "Cancel" : "Close", function() {
			if (creatingStrumLine && onSave != null) onSave(null);
			close();
		}, 125);
		add(closeButton);
		closeButton.color = 0xFFFF0000;
	}

	function saveStrumline() {
		for (stepper in [hudXStepper, hudYStepper, hudScaleStepper])
			@:privateAccess stepper.__onChange(stepper.label.text);

		var newStrumLine:ChartStrumLine = {
			characters: [
				for (char in charactersList.buttons.members)
					char.textBox.label.text.trim()
			],
			type: typeDropdown.index,
			notes: strumLine.notes,
			position: ["DAD", "BOYFRIEND", "GIRLFRIEND"][stagePositionDropdown.index].toLowerCase(),
			visible: strumLine.visible,
			strumPos: [hudXStepper.value, hudYStepper.value],
			strumScale: hudScaleStepper.value
		};
		if(!usesChartscrollSpeed.checked) newStrumLine.scrollSpeed = scrollSpeedStepper.value;
		if (onSave != null) onSave(newStrumLine);
	}
}

class CharacterButton extends UIButton {
	public var charIcon:HealthIcon;
	public var textBox:UIAutoCompleteTextBox;
	public var deleteButton:UIButton;
	public var deleteIcon:FlxSprite;

	public function new(x:Float, y:Float, char:String, charsList:Array<String>, parent:UIButtonList<CharacterButton>) {
		super(x, y, "", null, 250, 54);
		autoAlpha = false;

		charIcon = new HealthIcon(Character.getIconFromCharName(char));
		charIcon.scale.set(0.3, 0.3);
		charIcon.updateHitbox();
		charIcon.setPosition(x + 10, bHeight/2 - charIcon.height / 2);
		charIcon.scrollFactor.set(1,1);

		members.push(charIcon);

		members.push(textBox = new UIAutoCompleteTextBox(charIcon.x + charIcon.width + 16, bHeight/2 - (32/2), char, 115));
		textBox.suggestItems = charsList;
		textBox.antialiasing = true;
		textBox.onChange = function(char:String) {
			char = Character.getIconFromCharName(char);
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

		deleteIcon = new FlxSprite(deleteButton.x + (15/2), deleteButton.y + 8).loadGraphic(Paths.image('editors/character/delete-button'));
		deleteIcon.antialiasing = false;
		members.push(deleteIcon);
	}

	override function update(elapsed) {
		charIcon.y = y + bHeight / 2 - charIcon.height / 2;
		deleteButton.y = y + bHeight / 2 - deleteButton.bHeight / 2;
		textBox.y = y + bHeight/2 - 16;
		deleteIcon.x = deleteButton.x + (15/2); deleteIcon.y = deleteButton.y + 8;

		deleteButton.selectable = selectable;
		deleteButton.shouldPress = shouldPress;

		super.update(elapsed);
	}
}