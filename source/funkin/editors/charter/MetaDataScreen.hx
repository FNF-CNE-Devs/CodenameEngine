package funkin.editors.charter;

import flixel.math.FlxPoint;
import funkin.backend.chart.ChartData.ChartMetaData;

using StringTools;

class MetaDataScreen extends UISubstateWindow {
	public var metadata:ChartMetaData;
	public var saveButton:UIButton;
	public var closeButton:UIButton;

	public var songNameTextBox:UITextBox;
	public var bpmStepper:UINumericStepper;
	public var stepsPerBeatStepper:UINumericStepper;
	public var beatsPerMesureStepper:UINumericStepper;
	public var needsVoicesCheckbox:UICheckbox;

	public var displayNameTextBox:UITextBox;
	public var iconTextBox:UITextBox;
	public var iconSprite:FlxSprite;
	public var opponentModeCheckbox:UICheckbox;
	public var coopAllowedCheckbox:UICheckbox;
	public var colorWheel:UIColorwheel;
	public var difficulitesTextBox:UITextBox;

	public function new(metadata:ChartMetaData) {
		super();
		this.metadata = metadata;
		trace(metadata);
	}

	public override function create() {
		winTitle = "Edit Metadata";
		winWidth = 748 - 32 + 40;

		super.create();
		FlxG.sound.music.pause();

		function addLabelOn(ui:UISprite, text:String)
			add(new UIText(ui.x, ui.y - 24, 0, text));

		var title:UIText;
		add(title = new UIText(windowSpr.x + 20, windowSpr.y + 30 + 16, 0, "Song Data", 28));

		songNameTextBox = new UITextBox(title.x, title.y + title.height + 36, metadata.name);
		add(songNameTextBox);
		addLabelOn(songNameTextBox, "Song Name");

		bpmStepper = new UINumericStepper(songNameTextBox.x + 320 + 26, songNameTextBox.y, metadata.bpm, 1, 2, 1, null, 90);
		add(bpmStepper);
		addLabelOn(bpmStepper, "BPM");

		stepsPerBeatStepper = new UINumericStepper(bpmStepper.x + 60 + 26, bpmStepper.y, metadata.stepsPerBeat, 1, 0, 1, null, 54);
		add(stepsPerBeatStepper);
		addLabelOn(stepsPerBeatStepper, "Time Signature");

		add(new UIText(stepsPerBeatStepper.x + 30, stepsPerBeatStepper.y + 3, 0, "/", 22));

		beatsPerMesureStepper = new UINumericStepper(stepsPerBeatStepper.x + 30 + 24, stepsPerBeatStepper.y, metadata.beatsPerMesure, 1, 0, 1, null, 54);
		add(beatsPerMesureStepper);

		needsVoicesCheckbox = new UICheckbox(beatsPerMesureStepper.x + 80 + 26, beatsPerMesureStepper.y, "Voices", metadata.needsVoices);
		add(needsVoicesCheckbox);
		addLabelOn(needsVoicesCheckbox, "Needs Voices");
		needsVoicesCheckbox.y += 6; needsVoicesCheckbox.x += 4;

		add(title = new UIText(songNameTextBox.x, songNameTextBox.y + 10 + 46, 0, "Menus Data (Freeplay/Story)", 28));

		displayNameTextBox = new UITextBox(title.x, title.y + title.height + 36, metadata.displayName);
		add(displayNameTextBox);
		addLabelOn(displayNameTextBox, "Display Name");

		iconTextBox = new UITextBox(displayNameTextBox.x + 320 + 26, displayNameTextBox.y, metadata.icon, 150);
		iconTextBox.onChange = (newIcon:String) -> {updateIcon(newIcon);}
		add(iconTextBox);
		addLabelOn(iconTextBox, "Icon");

		updateIcon(metadata.icon);

		opponentModeCheckbox = new UICheckbox(displayNameTextBox.x, iconTextBox.y + 10 + 32 + 26, "Opponent Mode", metadata.opponentModeAllowed);
		add(opponentModeCheckbox);
		addLabelOn(opponentModeCheckbox, "Modes Allowed");

		coopAllowedCheckbox = new UICheckbox(opponentModeCheckbox.x + 150 + 26, opponentModeCheckbox.y, "Co-op Mode", metadata.coopAllowed);
		add(coopAllowedCheckbox);

		colorWheel = new UIColorwheel(iconTextBox.x, coopAllowedCheckbox.y, metadata.parsedColor);
		add(colorWheel);
		addLabelOn(colorWheel, "Color");

		difficulitesTextBox = new UITextBox(opponentModeCheckbox.x, opponentModeCheckbox.y + 6 + 32 + 26, metadata.difficulties.join(", "));
		add(difficulitesTextBox);
		addLabelOn(difficulitesTextBox, "Difficulties");

		for (checkbox in [opponentModeCheckbox, coopAllowedCheckbox])
			{checkbox.y += 6; checkbox.x += 4;}

		saveButton = new UIButton(windowSpr.x + windowSpr.bWidth - 20, colorWheel.y + 32 + 197 + 26, "Save & Close", function() {
			saveMeta();
			close();
		}, 125);
		saveButton.x -= saveButton.bWidth;
		saveButton.y -= saveButton.bHeight;

		closeButton = new UIButton(saveButton.x - 20, saveButton.y, "Close", function() {
			close();
		}, 125);
		closeButton.x -= closeButton.bWidth;
		//closeButton.y -= closeButton.bHeight;
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

	public function saveMeta() {
		PlayState.SONG.meta = {
			name: songNameTextBox.label.text,
			bpm: bpmStepper.value,
			stepsPerBeat: Std.int(stepsPerBeatStepper.value),
			beatsPerMesure: Std.int(beatsPerMesureStepper.value),
			needsVoices: needsVoicesCheckbox.checked,
			displayName: displayNameTextBox.label.text,
			icon: iconTextBox.label.text,
			color: colorWheel.curColorString,
			parsedColor: colorWheel.curColor,
			opponentModeAllowed: opponentModeCheckbox.checked,
			coopAllowed: coopAllowedCheckbox.checked,
			difficulties: [for (diff in difficulitesTextBox.label.text.split(",")) diff.trim()],
		};
	}
}