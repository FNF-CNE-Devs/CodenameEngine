package funkin.editors.character;

import flixel.math.FlxRandom;
import cpp.Random;
import flixel.math.FlxPoint;
import funkin.backend.utils.XMLUtil.AnimData;
import funkin.game.Character;

class DeleteAnimScreen extends UISubstateWindow
{
	public var char:Character;
	public var ghostChar:Character;

	public var editor:CharacterEditor;

	public var animButtons:FlxTypedSpriteGroup<UIButton> = new FlxTypedSpriteGroup<UIButton>(365, -10);

	public var closeButton:UIButton;

	public function new(char:Character, ghostChar:Character, editor:CharacterEditor)
	{
		super();
		this.char = char;
		this.ghostChar = ghostChar;
		this.editor = editor;
	}

	public override function create()
	{
		winTitle = "Delete Animation";
		winWidth = 480;
		winHeight = 700;

		super.create();

		add(animButtons);

		var y_adder = 60;
		for (anim in char.characterData.animations)
		{
			var newbutton = new UIButton(animButtons.x - 550, animButtons.y + y_adder, anim.name, function()
			{
				removeAnimation(anim);
				close();
			});
			animButtons.add(newbutton);
			y_adder += 45;
		}

		closeButton = new UIButton(windowSpr.x - 120, windowSpr.y + 20, "Close", function() {
			close();
		});
		add(closeButton);
	}

	public function removeAnimation(anim:AnimData)
	{
		var refreshAnim:Bool = false;
		if (char.animation.curAnim != null && anim.name == char.animation.curAnim.name)
			refreshAnim = true;

		if (char.animation.getByName(anim.name) != null)
			char.animation.remove(anim.name);
		if (char.animOffsets.exists(anim.name))
			char.animOffsets.remove(anim.name);
		char.characterData.animations.remove(anim);

		if (refreshAnim && char.characterData.animations.length > 0)
			char.playAnim(char.characterData.animations[0].name, true);

		editor.reloadGhost();
	}
}
