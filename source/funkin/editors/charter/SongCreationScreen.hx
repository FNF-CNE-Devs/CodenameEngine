package funkin.editors.charter;

import flixel.group.FlxGroup;
import funkin.backend.chart.ChartData;
import haxe.io.Bytes;

typedef SongCreationData = {
	var song:ChartData;
	var instBytes:Bytes;
	var voicesBytes:Bytes;
}

class SongCreationScreen extends UISubstateWindow {
	private var onSave:SongCreationData -> Void = null;

	public var songNameTextBox:UITextBox;
	public var bpmStepper:UINumericStepper;
	public var beatsPerMesureStepper:UINumericStepper;
	public var stepsPerBeatStepper :UINumericStepper;
	public var needsVoicesCheckbox:UICheckbox;

	public var displayNameTextBox:UITextBox;
	public var iconTextBox:UITextBox;
	public var iconSprite:FlxSprite;
	public var opponentModeCheckbox:UICheckbox;
	public var coopAllowedCheckbox:UICheckbox;
	public var colorWheel:UIColorwheel;
	public var difficulitesTextBox:UITextBox;

	public var backButton:UIButton;
	public var saveButton:UIButton;
	public var closeButton:UIButton;

	public var songDataGroup:FlxGroup = new FlxGroup();
	public var menuDataGroup:FlxGroup = new FlxGroup();

	public var pages:Array<FlxGroup> = [];
	public var pageSizes:Array<FlxPoint> = [];
	public var curPage:Int = 0;

	public function new(?onSave:SongCreationData->Void) {
		super();
		if (onSave != null) this.onSave = onSave;
	}

	public override function create() {
		winTitle = "Creating New Song";

		winWidth = 748 - 32 + 40;
		winHeight = 520;

		super.create();

		function addLabelOn(ui:UISprite, text:String)
			ui.members.push(new UIText(ui.x, ui.y - 24, 0, text));

		var songTitle:UIText;
		songDataGroup.add(songTitle = new UIText(windowSpr.x + 20, windowSpr.y + 30 + 16, 0, "Song Info", 28));

		songNameTextBox = new UITextBox(songTitle.x, songTitle.y + songTitle.height + 36, "Song Name");
		songDataGroup.add(songNameTextBox);
		addLabelOn(songNameTextBox, "Song Name");

		bpmStepper = new UINumericStepper(songNameTextBox.x + 320 + 26, songNameTextBox.y, 100, 1, 2, 1, null, 90);
		songDataGroup.add(bpmStepper);
		addLabelOn(bpmStepper, "BPM");

		beatsPerMesureStepper = new UINumericStepper(bpmStepper.x + 60 + 26, bpmStepper.y, 4, 1, 0, 1, null, 54);
		songDataGroup.add(beatsPerMesureStepper);
		addLabelOn(beatsPerMesureStepper, "Time Signature");

		songDataGroup.add(new UIText(beatsPerMesureStepper.x + 30, beatsPerMesureStepper.y + 3, 0, "/", 22));

		stepsPerBeatStepper = new UINumericStepper(beatsPerMesureStepper.x + 30 + 24, beatsPerMesureStepper.y, 4, 1, 0, 1, null, 54);
		songDataGroup.add(stepsPerBeatStepper);

		needsVoicesCheckbox = new UICheckbox(stepsPerBeatStepper.x + 80 + 26, stepsPerBeatStepper.y, "Voices", true);
		songDataGroup.add(needsVoicesCheckbox);
		addLabelOn(needsVoicesCheckbox, "Needs Voices");
		needsVoicesCheckbox.y += 6; needsVoicesCheckbox.x += 4;

		var menuTitle:UIText;
		menuDataGroup.add(menuTitle = new UIText(windowSpr.x + 20, windowSpr.y + 30 + 16, 0, "Menus Data (Freeplay/Story)", 28));

		displayNameTextBox = new UITextBox(menuTitle.x, menuTitle.y + menuTitle.height + 36, "Display Name");
		menuDataGroup.add(displayNameTextBox);
		addLabelOn(displayNameTextBox, "Display Name");

		iconTextBox = new UITextBox(displayNameTextBox.x + 320 + 26, displayNameTextBox.y, "Icon", 150);
		iconTextBox.onChange = (newIcon:String) -> {updateIcon(newIcon);}
		menuDataGroup.add(iconTextBox);
		addLabelOn(iconTextBox, "Icon");

		updateIcon("Icon");

		opponentModeCheckbox = new UICheckbox(displayNameTextBox.x, iconTextBox.y + 10 + 32 + 26, "Opponent Mode", true);
		menuDataGroup.add(opponentModeCheckbox);
		addLabelOn(opponentModeCheckbox, "Modes Allowed");

		coopAllowedCheckbox = new UICheckbox(opponentModeCheckbox.x + 150 + 26, opponentModeCheckbox.y, "Co-op Mode", true);
		menuDataGroup.add(coopAllowedCheckbox);

		colorWheel = new UIColorwheel(iconTextBox.x, coopAllowedCheckbox.y, 0xFFFFFF);
		menuDataGroup.add(colorWheel);
		addLabelOn(colorWheel, "Color");

		difficulitesTextBox = new UITextBox(opponentModeCheckbox.x, opponentModeCheckbox.y + 6 + 32 + 26, "");
		menuDataGroup.add(difficulitesTextBox);
		addLabelOn(difficulitesTextBox, "Difficulties");

		for (checkbox in [opponentModeCheckbox, coopAllowedCheckbox])
			{checkbox.y += 6; checkbox.x += 4;}

		saveButton = new UIButton(windowSpr.x + windowSpr.bWidth - 20 - 125, windowSpr.y + windowSpr.bHeight - 16 - 32, "Save & Close", function() {
			if (curPage == pages.length-1) {
				if (onSave != null) onSave(null);
				close();
			} else {
				curPage++;
				refreshPages();
			}

			updatePagesTexts();
		}, 125);
		add(saveButton);

		backButton = new UIButton(saveButton.x - 20 - saveButton.bWidth, saveButton.y, "< Back", function() {
			curPage--;
			refreshPages();

			updatePagesTexts();
		}, 125);
		add(backButton);

		closeButton = new UIButton(backButton.x - 20 - saveButton.bWidth, saveButton.y, "Cancel", function() {
			close();
		}, 125);
		add(closeButton);
		closeButton.color = 0xFFFF0000;

		pages.push(cast add(songDataGroup));
		pageSizes.push(FlxPoint.get(748 - 32 + 40, 520));

		pages.push(cast add(menuDataGroup));
		pageSizes.push(FlxPoint.get(748 - 32 + 40, 400));

		refreshPages();
		updatePagesTexts();
	}

	function refreshPages() {
		for (i=>page in pages)
			page.visible = page.exists = i == curPage;
	}

	function updatePagesTexts() {
		windowSpr.bWidth = Std.int(pageSizes[curPage].x);
		windowSpr.bHeight = Std.int(pageSizes[curPage].y);

		titleSpr.x = windowSpr.x + 25;
		titleSpr.y = windowSpr.y + ((30 - titleSpr.height) / 2);

		saveButton.field.text = curPage == pages.length-1 ? "Save & Close" : 'Next (${curPage+1+1}/${pages.length}) >';
		titleSpr.text = 'Creating New Song (${curPage+1}/${pages.length})';

		backButton.field.text = '< (${curPage}/${pages.length}) Back';
		backButton.visible = backButton.exists = curPage > 0;

		backButton.x = (saveButton.x = windowSpr.x + windowSpr.bWidth - 20 - 125) - 20 - saveButton.bWidth;
		closeButton.x = (curPage > 0 ? backButton : saveButton).x - 20 - saveButton.bWidth;

		for (button in [saveButton, backButton, closeButton])
			button.y = windowSpr.y + windowSpr.bHeight - 16 - 32;
	}

	function updateIcon(icon:String) {
		if (iconSprite == null) menuDataGroup.add(iconSprite = new FlxSprite());

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