package funkin.editors.character;

import flixel.util.FlxColor;
import funkin.game.Character;
import funkin.backend.chart.Chart;
import funkin.game.Character.CharacterData;
import funkin.options.type.TextOption;
import funkin.options.type.IconOption;
import funkin.options.OptionsScreen;
import sys.FileSystem;

class CharacterSelection extends EditorTreeMenu
{
	public var characterList:CharactersList;

	public override function create()
	{
		bgType = "charter";

		super.create();

		characterList = CharactersList.get();

		main = new OptionsScreen("Character Editor", "Select a character to edit", [
			for (s in characterList.characters)
				new IconOption(s.name, "Press ACCEPT to edit this character.", s.icon, function()
				{
					FlxG.switchState(new CharacterEditor(s.name));
				})
		]);
	}

	public override function update(elapsed:Float)
	{
		super.update(elapsed);
	}

	public override function onMenuChange() {
		super.onMenuChange();
		if (optionsTree.members.length > 1) { // selected a song
			// small flashbang
			var color:FlxColor = characterList.characters[main.curSelected].iconColor.getDefault(0xFFFFFFFF);

			bg.colorTransform.redOffset = 0.25 * color.red;
			bg.colorTransform.greenOffset = 0.25 * color.green;
			bg.colorTransform.blueOffset = 0.25 * color.blue;
			bg.colorTransform.redMultiplier = FlxMath.lerp(1, color.redFloat, 0.25);
			bg.colorTransform.greenMultiplier = FlxMath.lerp(1, color.greenFloat, 0.25);
			bg.colorTransform.blueMultiplier = FlxMath.lerp(1, color.blueFloat, 0.25);
		}
	}
}

class CharactersList
{
	public var characters:Array<CharacterData> = [];

	public function new()
	{
	}

	public function getCharactersFromSource(source:funkin.backend.assets.AssetsLibraryList.AssetSource)
	{
		var charactersFound:Array<String> = [];

		charactersFound = Paths.getFolderContent('data/characters', false, source);

		if (charactersFound.length > 0)
		{
			for (s in charactersFound)
				if (s.endsWith(".xml"))
					characters.push(CharacterConfig.loadCharacterData(s.replace(".xml", "")));
			return true;
		}
		return false;
	}

	public static function get()
	{
		var characterList = new CharactersList();

		if (!characterList.getCharactersFromSource(MODS))
			characterList.getCharactersFromSource(SOURCE);

		return characterList;
	}
}
