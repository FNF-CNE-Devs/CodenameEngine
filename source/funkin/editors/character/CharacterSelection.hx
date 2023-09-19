package funkin.editors.character;

import funkin.options.type.OptionType;
import funkin.options.type.NewOption;
import flixel.util.FlxColor;
import funkin.game.Character;
import funkin.backend.chart.Chart;
import funkin.options.type.TextOption;
import funkin.options.type.IconOption;
import funkin.options.OptionsScreen;

class CharacterSelection extends EditorTreeMenu
{
	public override function create()
	{
		bgType = "charter";
		super.create();

		var modsList:Array<String> = Character.getList(true);

		var list:Array<OptionType> = [
			for (char in (modsList.length == 0 ? Character.getList(false) : modsList))
				new IconOption(char, "Press ACCEPT to edit this character.", Character.getIconFromCharName(char),
			 	function() {
					FlxG.switchState(new CharacterEditor(char));
				})
		];

		list.insert(0, new NewOption("New Character", "New Character", function() {
			openSubState(new UIWarningSubstate("New Character: Feature Not Implemented!", "This feature isnt implemented yet. Please wait for more cne updates to have this functional.\n\n\n- Codename Devs", [
				{label: "Ok", color: 0xFFFF0000, onClick: function(t) {}}
			]));
		}));

		main = new OptionsScreen("Character Editor", "Select a character to edit", list);
	}

	override function createPost() {
		super.createPost();

		main.changeSelection(1);
	}
}