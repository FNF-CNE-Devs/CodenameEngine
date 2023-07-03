package funkin.editors.charter;

import flixel.math.FlxPoint;
import funkin.game.Note;
import funkin.game.Character;
import funkin.game.HealthIcon;
import funkin.backend.chart.ChartData.ChartStrumLine;

class CharterStrumlineScreen extends UISubstateWindow {
	public var strumLineID:Int = -1;
	public var strumLine:ChartStrumLine;

	public var charactersTextBox:UITextBox;
	public var typeDropdown:UIDropDown;
	public var stagePositionDropdown:UIDropDown;
	public var hudScaleStepper:UINumericStepper;
	public var hudXStepper:UINumericStepper;
	public var hudYStepper:UINumericStepper;

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

		winTitle = creatingStrumLine ? 'Creating Strumline #$strumLineID' : 'Strumline #$strumLineID properties';
		winWidth = 690; winHeight = 334;

		FlxG.sound.music.pause();
		Charter.instance.vocals.pause();

		super.create();

		function addLabelOn(ui:UISprite, text:String)
			add(new UIText(ui.x, ui.y - 24, 0, text));

		var title:UIText;
		add(title = new UIText(windowSpr.x + 20, windowSpr.y + 30 + 16, 0, creatingStrumLine ? "Create New Strumline" : "Edit Strumline Properties", 28));

		charactersTextBox = new UITextBox(title.x, title.y + title.height + 38, strumLine.characters.join(", "));
		charactersTextBox.onChange = (newChars:String) -> {
			updateCharacterIcons([for (char in newChars.split(",")) char.trim()]);
		};
		add(charactersTextBox);
		addLabelOn(charactersTextBox, "Characters");

		updateCharacterIcons(strumLine.characters);

		typeDropdown = new UIDropDown(charactersTextBox.x, charactersTextBox.y + 32 + 58, 200, 32, ["OPPONENT", "PLAYER", "ADDITIONAL"], strumLine.type);
		add(typeDropdown);
		addLabelOn(typeDropdown, "Type");

		var stagePositionI = strumLine.position == null ? strumLine.type : ["DAD", "BOYFRIEND", "GIRLFRIEND"].indexOf(strumLine.position.toUpperCase());

		stagePositionDropdown = new UIDropDown(typeDropdown.x + 200 - 32 + 26, typeDropdown.y, 200, 32, ["DAD", "BOYFRIEND", "GIRLFRIEND"], stagePositionI);
		add(stagePositionDropdown);
		addLabelOn(stagePositionDropdown, "Stage Position");

		hudScaleStepper = new UINumericStepper(stagePositionDropdown.x + 200 - 32 + 26, stagePositionDropdown.y, strumLine.strumScale == null ? 1 : strumLine.strumScale, 0.001, 2, null, null, 74);
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
			if (creatingStrumLine) onSave(null);
			close();
		}, 125);
		add(closeButton);
		closeButton.x -= closeButton.bWidth;
	}

	function updateCharacterIcons(characters:Array<String>) {
		for (icon in characterIcons) {
			remove(icon);
			icon.destroy();
		}
		characterIcons = [];

		for (i => char in characters) {
			var iconSprite = new HealthIcon(Character.getIconFromCharName(char));
			iconSprite.scrollFactor.set(1,1);
			iconSprite.scale.set(0.5, 0.5);
			iconSprite.updateHitbox();

			iconSprite.setPosition(
				charactersTextBox.x + 320 + 8 + ((iconSprite.width + 4) * i),
				(charactersTextBox.y + 16) - (iconSprite.height/2)
			);
			add(iconSprite);
			characterIcons.push(iconSprite);
		}
	}

	function saveStrumline() {
		for (stepper in [hudXStepper, hudYStepper, hudScaleStepper])
			@:privateAccess stepper.__onChange(stepper.label.text);

		strumLine = {
			characters: [for (char in charactersTextBox.label.text.split(",")) char.trim()],
			type: typeDropdown.index,
			notes: strumLine.notes,
			position: ["DAD", "BOYFRIEND", "GIRLFRIEND"][stagePositionDropdown.index].toLowerCase(),
			visible: strumLine.visible,
			strumPos: [hudXStepper.value, hudYStepper.value],
			strumScale: hudScaleStepper.value
		};
		if (onSave != null) onSave(strumLine);
	}
}