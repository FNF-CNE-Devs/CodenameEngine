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

		charactersList = new UIButtonList<CharacterButton>(15, 43, 250, 330, "", FlxPoint.get(246, 75), null, 0);
		charactersList.addButton.callback = () -> charactersList.add(new CharacterButton(0,0,"New Char", charactersList));
		for (i in strumLine.characters) 
			charactersList.add(new CharacterButton(0,0,i, charactersList));
		charactersList.cameraSpacing = 2;
		add(charactersList);

		charactersList.frames = Paths.getFrames('editors/ui/inputbox');

		typeDropdown = new UIDropDown(charactersList.x + 265, charactersList.y + 20, 200, 32, ["OPPONENT", "PLAYER", "ADDITIONAL"], strumLine.type);
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

		closeButton = new UIButton(saveButton.x - 20, saveButton.y, creatingStrumLine ? "Cancel" : "Close", function() {
			if (creatingStrumLine && onSave != null) onSave(null);
			close();
		}, 125);
		add(closeButton);
		closeButton.color = 0xFFFF0000;
		closeButton.x -= closeButton.bWidth;
	}

	function saveStrumline() {
		for (stepper in [hudXStepper, hudYStepper, hudScaleStepper])
			@:privateAccess stepper.__onChange(stepper.label.text);

		strumLine = {
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
		if(!usesChartscrollSpeed.checked) strumLine.scrollSpeed = scrollSpeedStepper.value;
		if (onSave != null) onSave(strumLine);
	}
}

class CharacterButton extends UIButton {
	public var charIcon:HealthIcon;
	public var textBox:UITextBox;
	public var deleteButton:UIButton;
	public var deleteIcon:FlxSprite;

	public function new(x:Float, y:Float, char:String, parent:UIButtonList<CharacterButton>) {
		charIcon = new HealthIcon(char);
		charIcon.scale.set(0.5, 0.5);
		charIcon.updateHitbox();
		super(x, y, "", null, 246, Math.floor(charIcon.height));
		charIcon.setPosition(x + 10, bHeight/2 - charIcon.height / 2);
		members.push(charIcon);
		members.remove(field);
		members.push(textBox = new UITextBox(95, bHeight/2 - 16, char, 100));
		textBox.antialiasing = true;
		textBox.onChange = function(char:String) {
			charIcon.loadGraphic(Assets.exists(Paths.image("icons/" + char)) ? Paths.image("icons/" + char) : Paths.image("icons/face"), true, 150, 150);
			charIcon.updateHitbox();
		}
		deleteButton = new UIButton(textBox.x + 105, y, "", function () {
			parent.remove(this);
		}, 32);
		deleteButton.color = 0xFFFF0000;
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