package funkin.editors.character;

import flixel.math.FlxRandom;
import cpp.Random;
import flixel.math.FlxPoint;
import funkin.backend.utils.XMLUtil.AnimData;
import funkin.game.Character;

class SelectAnimUpdate extends UISubstateWindow
{
	public var cancelButton:UIButton;

	public var char:Character;
	public var ghostChar:Character;

	public var editor:CharacterEditor;

	public var animButtons:FlxTypedSpriteGroup<UIButton> = new FlxTypedSpriteGroup<UIButton>(365, -10);

	public function new(char:Character, ghostChar:Character, editor:CharacterEditor)
	{
		super();
		this.char = char;
		this.ghostChar = ghostChar;
		this.editor = editor;
	}

	public override function create()
	{
		winTitle = "Select an animation to update:";
		winWidth = 480;
		winHeight = 700;

		super.create();

		add(animButtons);

		var y_ofs = 60;

		for (anim in char.characterData.animations)
		{
			var newbutton = new UIButton(animButtons.x - 550, animButtons.y + y_ofs, anim.name, function()
			{
				openUpdateWindow(anim);
			});
			animButtons.add(newbutton);
			y_ofs += 45;
		}

		cancelButton = new UIButton(windowSpr.x - 10, windowSpr.y + 20, "Cancel", function()
		{
			close();
		});
		cancelButton.x -= cancelButton.bWidth;
		add(cancelButton);
	}

	public function openUpdateWindow(anim:AnimData)
	{
		openSubState(new UpdateAnimScreen(this.char, this.ghostChar, anim, this.editor));
	}
}
