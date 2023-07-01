package funkin.editors.character;

import flixel.math.FlxPoint;
import funkin.backend.utils.XMLUtil.AnimData;
import funkin.game.Character;

class UpdateAnimScreen extends UISubstateWindow
{
	public var char:Character;
	public var ghostChar:Character;

	public var updateButton:UIButton;
	public var cancelButton:UIButton;
	public var editor:CharacterEditor;

	public var curAnimData:AnimData;

	public var animName:UITextBox;
	public var animPrefix:UITextBox;
	public var fps:UITextBox;
	public var loop:UICheckbox;
	public var indices:UITextBox;

	public function new(char:Character, ghostChar, animData:AnimData, editor:CharacterEditor)
	{
		super();
		this.char = char;
		this.ghostChar = ghostChar;
		this.curAnimData = animData;
		this.editor = editor;
	}

	public override function create()
	{
		winTitle = 'Update Animation: ${curAnimData.name}';
		winWidth = 960;

		super.create();

		// Animation Properties
		var y_ofs = 60;
		var y_text_ofs = 20;

		animName = new UITextBox(windowSpr.x + 50, windowSpr.y + y_ofs, curAnimData.name);
		add(animName);
		add(new UIText(animName.x, animName.y - y_text_ofs, -1, "Animation Name: "));

		animPrefix = new UITextBox(animName.x, animName.y + y_ofs, curAnimData.anim);
		add(animPrefix);
		add(new UIText(animPrefix.x, animPrefix.y - y_text_ofs, -1, "Animation on XML/Atlas file: "));

		fps = new UITextBox(animPrefix.x, animPrefix.y + y_ofs, Std.string(curAnimData.fps));
		add(fps);
		add(new UIText(fps.x, fps.y - y_text_ofs, -1, "Framerate: "));

		loop = new UICheckbox(fps.x, fps.y + y_ofs, "Looped", curAnimData.loop);
		add(loop);

		indices = new UITextBox(loop.x, loop.y + y_ofs, Std.string(curAnimData.indices).replace("[", "").replace("]", ""));
		add(indices);
		add(new UIText(indices.x, indices.y - y_text_ofs, -1, "Indices (0, 1, 2, 3): "));

		// Add / Cancel Buttons
		updateButton = new UIButton(windowSpr.x - 10, windowSpr.y + 31, "Update", function()
		{
			updateAnimation(animName.label.text, animPrefix.label.text, Std.parseInt(fps.label.text), loop.checked, indices.label.text);
			close();
		});
		updateButton.x -= updateButton.bWidth;
		add(updateButton);

		cancelButton = new UIButton(updateButton.x, updateButton.y + y_ofs, "Cancel", function()
		{
			close();
		});
		add(cancelButton);
	}

	public function updateAnimation(name:String, ?anim:String, ?fps:Int = 24, ?looped:Bool = false, ?indices:String)
	{
		var animType:XMLAnimType = NONE;

		var selectedAnim:AnimData = null;
		var selectedAnimIndex = 0;

		for (i in 0...char.characterData.animations.length)
		{
			if (char.characterData.animations[i].name == name)
			{
				selectedAnim = char.characterData.animations[i];
				selectedAnimIndex = i;
			}
		}

		if (selectedAnim == null)
			return;

		var animData:AnimData = {
			name: name,
			anim: anim,
			fps: fps,
			loop: looped,
			animType: animType,
			indices: [],
			x: selectedAnim.x,
			y: selectedAnim.y
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
		char.characterData.animations[selectedAnimIndex] = animData;
		char.playAnim(name, true);
	}
}
