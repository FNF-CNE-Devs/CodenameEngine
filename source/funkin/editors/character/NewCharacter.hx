package funkin.editors.character;

import flixel.util.FlxColor;
import flixel.math.FlxPoint;
import funkin.backend.utils.XMLUtil.AnimData;
import funkin.game.Character;
import funkin.editors.character.DeleteAnimScreen;

class NewCharacter extends UISubstateWindow
{
	public var char:Character;
	public var ghostChar:Character;
	public var charData:CharacterData;

	public var applyButton:UIButton;
	public var nextButton:UIButton;
	public var cancelButton:UIButton;
	public var editor:CharacterEditor;

	public var curAnimData:AnimData;

	public var spriteFile:UITextBox;
	public var gameOverChar:UITextBox;
	public var healthIcon:UITextBox;
	public var iconColor:UITextBox;
	public var flipX:UICheckbox;
	public var isPlayer:UICheckbox;
	public var isGF:UICheckbox;
	public var antialiasing:UICheckbox;
	public var scale:UITextBox;
	public var holdTime:UITextBox;

	public function new(char:Character, ghostChar, editor:CharacterEditor)
	{
		super();
		this.char = char;
		this.ghostChar = ghostChar;
		this.charData = char.characterData;
		this.editor = editor;

		//TO DO: Generate and Save
		//----


		//Delete old Animaitons
	}

	public override function create()
	{
		winTitle = 'Create New Character';
		winWidth = 960;

		super.create();

		// Offsets
		var y_ofs = 60;
		var x_ofs = 60;
		var y_text_ofs = 20;

		// Character Properties
		spriteFile = new UITextBox(windowSpr.x + 50, windowSpr.y + 10 + y_ofs, charData.sprite);
		add(spriteFile);
		add(new UIText(spriteFile.x, spriteFile.y - y_text_ofs, -1, "Image/Atlas file: "));

		gameOverChar = new UITextBox(spriteFile.x + spriteFile.bWidth + x_ofs, spriteFile.y, charData.gameOverChar);
		add(gameOverChar);
		add(new UIText(gameOverChar.x, gameOverChar.y - y_text_ofs, -1, "Game Over character: "));

		healthIcon = new UITextBox(spriteFile.x, spriteFile.y + y_ofs, charData.icon);
		add(healthIcon);
		add(new UIText(healthIcon.x, healthIcon.y - y_text_ofs, -1, "Health Icon: "));

		iconColor = new UITextBox(healthIcon.x + healthIcon.bWidth + x_ofs, healthIcon.y, CharacterConfig.rgbToString(charData.iconColor));
		add(iconColor);
		add(new UIText(iconColor.x, iconColor.y - y_text_ofs, -1, "Icon color (RGB): "));

		flipX = new UICheckbox(healthIcon.x, healthIcon.y + y_ofs, "Flip X", charData.flipX);
		add(flipX);

		antialiasing = new UICheckbox(flipX.x + flipX.field.width + x_ofs, flipX.y, "Antialiasing", charData.antialiasing);
		add(antialiasing);

		isPlayer = new UICheckbox(flipX.x, flipX.y + y_ofs, "Playable Character", charData.isPlayer);
		add(isPlayer);

		isGF = new UICheckbox(isPlayer.x + isPlayer.field.width + x_ofs, isPlayer.y, "GF Character", charData.isGF);
		add(isGF);

		scale = new UITextBox(isPlayer.x, isPlayer.y + y_ofs, Std.string(charData.scale));
		add(scale);
		add(new UIText(scale.x, scale.y - y_text_ofs, -1, "Scale: "));

		holdTime = new UITextBox(scale.x + scale.bWidth + y_ofs, scale.y, Std.string(charData.holdTime));
		add(holdTime);
		add(new UIText(holdTime.x, holdTime.y - y_text_ofs, -1, "Hold time: "));

		// Apply / Cancel buttons


		applyButton = new UIButton(windowSpr.x - x_ofs - 70, windowSpr.y, "Apply", function()
		{
			
			updateProperties(spriteFile.label.text, healthIcon.label.text, CharacterConfig.stringToRGB(healthIcon.label.text), flipX.checked,
			antialiasing.checked, isPlayer.checked, isGF.checked, Std.parseFloat(scale.label.text), Std.parseFloat(holdTime.label.text), gameOverChar.label.text);
			
			//TO DO: Add a Animation
		});
		add(applyButton);

		cancelButton = new UIButton(applyButton.x, applyButton.y + y_ofs, "Cancel", function()
		{
			close();
		});
		add(cancelButton);
	}

	public function updateProperties(sprite:String, healthIcon:String, iconColor:FlxColor, flipX:Bool, antialiasing:Bool, isPlayer:Bool, isGF:Bool,
			scale:Float, holdTime:Float, gameOverChar:String)
	{
		// Character Data
		charData.sprite = sprite;
		charData.icon = healthIcon;
		charData.iconColor = iconColor;
		charData.flipX = flipX;
		charData.antialiasing = antialiasing;
		charData.isPlayer = isPlayer;
		charData.isGF = isGF;
		charData.scale = scale;
		charData.holdTime = holdTime;
		charData.gameOverChar = gameOverChar;

		//Bring Player Char to Default Position for User
		if(isPlayer)
			{
				charData.offsetX = 770;
				charData.offsetY = 410;
			}
			else if(isGF)
			{
				charData.offsetX = 400;
				charData.offsetY = 330;
			}
			else
			{
				charData.offsetX = 100;
				charData.offsetY = 410;
			}




		editor.reloadChar(!char.isPlayer, charData);
		editor.reloadStage();
		editor.loadCross();



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
		}
}
