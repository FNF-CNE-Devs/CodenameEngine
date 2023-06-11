package funkin.editors.character;

import flixel.math.FlxPoint;
import funkin.backend.utils.XMLUtil.AnimData;
import funkin.game.Character;

class AddAnimScreen extends UISubstateWindow
{
	public var char:Character;
	public var ghostChar:Character;

	public var addButton:UIButton;
	public var cancelButton:UIButton;
	public var editor:CharacterEditor;

	public var animName:UITextBox;
	public var animPrefix:UITextBox;
	public var fps:UITextBox;
	public var loop:UICheckbox;
	public var indices:UITextBox;

	public function new(char:Character, ghostChar, editor:CharacterEditor)
	{
		super();
		this.char = char;
		this.ghostChar = ghostChar;
	}

	public override function create()
	{
		winTitle = "Add new Animation";
		winWidth = 960;

		super.create();

		// Animation Properties
		var y_ofs = 60;
		var y_text_ofs = 20;

		animName = new UITextBox(windowSpr.x + 50, windowSpr.y + y_ofs, "");
		add(animName);
		add(new UIText(animName.x, animName.y - y_text_ofs, -1, "Animation Name: "));

		animPrefix = new UITextBox(animName.x, animName.y + y_ofs, "");
		add(animPrefix);
		add(new UIText(animPrefix.x, animPrefix.y - y_text_ofs, -1, "Animation on XML/Atlas file: "));

		fps = new UITextBox(animPrefix.x, animPrefix.y + y_ofs, "24");
		add(fps);
		add(new UIText(fps.x, fps.y - y_text_ofs, -1, "Framerate: "));

		loop = new UICheckbox(fps.x, fps.y + y_ofs, "Looped", false);
		add(loop);

		indices = new UITextBox(loop.x, loop.y + y_ofs, "");
		add(indices);
		add(new UIText(indices.x, indices.y - y_text_ofs, -1, "Indices (0, 1, 2, 3): "));

		// Add / Cancel Buttons
		addButton = new UIButton(windowSpr.x + 1, windowSpr.y + 31, "", function()
		{
			newAnimation(animName.label.text, animPrefix.label.text, Std.parseInt(fps.label.text), loop.checked, indices.label.text);
			close();
		});
		addButton.bWidth = addButton.bHeight = 30;
		add(addButton);

		var addButtonIcon = new FlxSprite(addButton.x, addButton.y, Paths.image('editors/charter/add-button'));
		addButtonIcon.x += (30 - addButtonIcon.width) / 2;
		addButtonIcon.y += (30 - addButtonIcon.height) / 2;
		add(addButtonIcon);

		cancelButton = new UIButton(addButton.x - 10, addButton.y, "Cancel", function()
		{
			close();
		});
		cancelButton.x -= cancelButton.bWidth;
		add(cancelButton);
	}

	public function newAnimation(name:String, anim:String, ?fps:Int = 24, ?looped:Bool = false, ?indices:String)
	{
		var animType:XMLAnimType = NONE;

		var animData:AnimData = {
			name: name,
			anim: anim,
			fps: fps,
			loop: looped,
			animType: animType,
			indices: [],
			x: 0,
			y: 0
		};

		if (indices != "" && indices != null)
		{
			var indicesSplit = indices.split(",");

			for (indice in indicesSplit)
			{
				var i = Std.parseInt(indice.trim());
				if (i != null)
					animData.indices.push(i);
			}
		}
		
		XMLUtil.addAnimToSprite(char, animData);
		XMLUtil.addAnimToSprite(ghostChar, animData);
		char.characterData.animations.push(animData);
		ghostChar.characterData.animations.push(animData);
	}
}
