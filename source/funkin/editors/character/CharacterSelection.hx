package funkin.editors.character;

import flixel.util.FlxColor;
import funkin.game.Character;
import funkin.backend.chart.Chart;
import funkin.options.type.TextOption;
import funkin.options.type.IconOption;
import funkin.options.OptionsScreen;
import sys.FileSystem;

class CharacterSelection extends EditorTreeMenu
{
	public override function create()
	{
		bgType = "charter";

		super.create();

		main = new OptionsScreen("Character Editor", "Select a character to edit", [
			for (char in Character.getList(true))
				new IconOption(char, "Press ACCEPT to edit this character.", Character.getIconFromCharName(char),
			 	function() {
					FlxG.switchState(new CharacterEditor(char));
				})
		]);
	}
}