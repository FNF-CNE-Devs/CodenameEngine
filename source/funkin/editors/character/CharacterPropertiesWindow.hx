package funkin.editors.character;

import flixel.util.FlxColor;

class CharacterPropertiesWindow extends UIWindow {
	public var newButton:UIButton;
	public var editButton:UIButton;

	public var characterInfo:UIText;

	public function new() {
		super(800-23,23 + 23, 450 + 23, 140, "Character Properties");

		newButton = new UIButton( x +(450 + 23)- 25 - 3 - 200, y + 12 + 31, "New Character", null, 200);
		members.push(newButton);
		newButton.color = FlxColor.GREEN;

		editButton = new UIButton(newButton.x, newButton.y + 12 + 30 + 4, "Edit Character Info", function () {
			CharacterEditor.instance.editInfoWithUI();
		}, 200);
		members.push(editButton);

		characterInfo = new UIText(x + 450 + 20 - 42 - 400, y + 36 + 10, 400, "0 Animations:\nFlipped:\nSprite:\nAnim:\nOffset: (,)");
		characterInfo.alignment = LEFT;
		members.push(characterInfo);
	}
}