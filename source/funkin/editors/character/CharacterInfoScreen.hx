package funkin.editors.character;

import funkin.game.Character;

class CharacterInfoScreen extends UISubstateWindow {
	public var character:Character;

	public var spriteTextBox:UITextBox;
	public var iconTextBox:UITextBox;
	public var iconSprite:FlxSprite;
	public var gameOverCharTextBox:UITextBox;
	public var positionXStepper:UINumericStepper;
	public var positionYStepper:UINumericStepper;
	public var cameraXStepper:UINumericStepper;
	public var cameraYStepper:UINumericStepper;
	public var scaleStepper:UINumericStepper;
	public var singTimeStepper:UINumericStepper;
	public var isPlayerCheckbox:UICheckbox;
	// TODO: ADD THESE OPTIONS AND A HEALTH BAR COLOR OPTION
	public var isGFCheckbox:UICheckbox;
	public var flipXCheckbox:UICheckbox;
	public var antialiasingCheckbox:UICheckbox;

	public var saveButton:UIButton;
	public var closeButton:UIButton;

	public function new(character:Character) {
		super();
		this.character = character;
	}

	public override function create() {
		winTitle = "Editing Character";
		winWidth = 960;

		super.create();

		function addLabelOn(ui:UISprite, text:String)
			add(new UIText(ui.x, ui.y - 24, 0, text));

		var title:UIText;
		add(title = new UIText(windowSpr.x + 20, windowSpr.y + 30 + 16, 0, "Sprite Data", 28));

		spriteTextBox = new UITextBox(title.x, title.y + title.height + 38, character.sprite, 200);
		add(spriteTextBox);
		addLabelOn(spriteTextBox, "Sprite");

		iconTextBox = new UITextBox(spriteTextBox.x + 200 + 26, spriteTextBox.y, character.getIcon(), 150);
		iconTextBox.onChange = (newIcon:String) -> {updateIcon(newIcon);}
		add(iconTextBox);
		addLabelOn(iconTextBox, "Icon");

		updateIcon(character.getIcon());

		gameOverCharTextBox = new UITextBox(iconTextBox.x + 150 + (75 + 16), iconTextBox.y, character.gameOverCharacter, 200);
		add(gameOverCharTextBox);
		addLabelOn(gameOverCharTextBox, "Game Over Character");

		add(title = new UIText(spriteTextBox.x, spriteTextBox.y + 10 + 46, 0, "Character Data", 28));

		positionXStepper = new UINumericStepper(title.x, title.y + title.height + 36, character.globalOffset.x, 0.001, 2, null, null, 84);
		add(positionXStepper);
		addLabelOn(positionXStepper, "Position (X,Y)");

		add(new UIText(positionXStepper.x + 84 - 32 + 0, positionXStepper.y + 9, 0, ",", 22));

		positionYStepper = new UINumericStepper(positionXStepper.x + 84 - 32 + 26, positionXStepper.y, character.globalOffset.y, 0.001, 2, null, null, 84);
		add(positionYStepper);

		cameraXStepper = new UINumericStepper(positionYStepper.x + 36 + 84 - 32, positionYStepper.y, character.cameraOffset.x, 0.001, 2, null, null, 84);
		add(cameraXStepper);
		addLabelOn(cameraXStepper, "Camera Position (X,Y)");

		add(new UIText(cameraXStepper.x + 84 - 32 + 0, cameraXStepper.y + 9, 0, ",", 22));

		cameraYStepper = new UINumericStepper(cameraXStepper.x + 84 - 32 + 26, cameraXStepper.y, character.cameraOffset.y, 0.001, 2, null, null, 84);
		add(cameraYStepper);

		scaleStepper = new UINumericStepper(cameraYStepper.x + 84 - 32 + 90, cameraYStepper.y, character.scale.x, 0.001, 2, null, null, 74);
		add(scaleStepper);
		addLabelOn(scaleStepper, "Scale");

		singTimeStepper = new UINumericStepper(scaleStepper.x + 74 - 32 + 36, scaleStepper.y, character.holdTime, 0.001, 2, null, null, 74);
		add(singTimeStepper);
		addLabelOn(singTimeStepper, "Sing Duration (Steps)");

		isPlayerCheckbox = new UICheckbox(positionXStepper.x, positionXStepper.y + 10 + 32 + 26, "isPlayer", character.playerOffsets);
		add(isPlayerCheckbox);
		addLabelOn(isPlayerCheckbox, "Is Player");

		for (checkbox in [isPlayerCheckbox])
			{checkbox.y += 6; checkbox.x += 4;}

		saveButton = new UIButton(windowSpr.x + windowSpr.bWidth - 20, windowSpr.y + windowSpr.bHeight- 20, "Save & Close", function() {
			close();
		}, 125);
		saveButton.x -= saveButton.bWidth;
		saveButton.y -= saveButton.bHeight;

		closeButton = new UIButton(saveButton.x - 20, saveButton.y, "Close", function() {
			close();
		}, 125);
		closeButton.x -= closeButton.bWidth;
		add(closeButton);
		add(saveButton);
	}

	function updateIcon(icon:String) {
		if (iconSprite == null) add(iconSprite = new FlxSprite());

		if (iconSprite.animation.exists(icon)) return;
		@:privateAccess iconSprite.animation.clearAnimations();

		var path:String = Paths.image('icons/$icon');
		if (!Assets.exists(path)) path = Paths.image('icons/face');

		iconSprite.loadGraphic(path, true, 150, 150);
		iconSprite.animation.add(icon, [0], 0, false);
		iconSprite.antialiasing = true;
		iconSprite.animation.play(icon);

		iconSprite.scale.set(0.5, 0.5);
		iconSprite.updateHitbox();
		iconSprite.setPosition(iconTextBox.x + 150 + 8, (iconTextBox.y + 16) - (iconSprite.height/2));
	}
}