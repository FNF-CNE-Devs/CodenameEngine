package funkin.editors.charter;

import funkin.options.type.NewOption;
import funkin.backend.system.framerate.Framerate;
import flixel.util.FlxColor;
import funkin.menus.FreeplayState.FreeplaySonglist;
import funkin.editors.EditorTreeMenu;
import funkin.options.*;
import funkin.options.type.*;

class CharterSelection extends EditorTreeMenu {
	public var freeplayList:FreeplaySonglist;
	public override function create() {
		bgType = "charter";

		super.create();

		Framerate.offset.y = 60;

		freeplayList = FreeplaySonglist.get(false);

		var list:Array<OptionType> = [
			for(s in freeplayList.songs) new IconOption(s.name, "Press ACCEPT to choose a difficulty to edit.", s.icon, function() {
				var list:Array<OptionType> = [
					for(d in s.difficulties) new TextOption(d, "Press ACCEPT to edit the chart for the selected difficulty", function() {
						FlxG.switchState(new Charter(s.name, d));
					})
				];
				list.push(new NewOption("New Difficulty", "New Difficulty", function() {

				}));
				optionsTree.add(new OptionsScreen(s.name, "Select a difficulty to continue, or press 1 to add a new one.", list));
			})
		];

		list.insert(0, new NewOption("New Chart", "New Chart", function() {

		}));

		main = new OptionsScreen("Chart Editor", "Select a song to modify the charts from.", list);
	}

	override function createPost() {
		super.createPost();

		var idk:OptionsScreen = optionsTree.members.last();
		if (idk.members.length > 0) idk.changeSelection(1);
	}
}