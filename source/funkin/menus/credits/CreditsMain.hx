package funkin.menus.credits;

import flixel.addons.transition.FlxTransitionableState;
import funkin.options.OptionsScreen;
import funkin.options.type.*;
import funkin.options.TreeMenu;

class CreditsMain extends TreeMenu {
	var editable:Array<OptionCategory> = [];
	var bg:FlxSprite;

	public override function create() {
		bg = new FlxSprite(-80).loadAnimatedGraphic(Paths.image('menus/menuBGBlue'));
		// bg.scrollFactor.set();
		bg.scale.set(1.15, 1.15);
		bg.updateHitbox();
		bg.screenCenter();
		bg.scrollFactor.set();
		bg.antialiasing = true;
		add(bg);

		var selectables:Array<OptionType> = [];
		for (s in editable) selectables.push(new TextOption(s.name, s.desc, function() {
			// TODO: Custom Credits
		}));
		selectables.push(new TextOption("Codename Engine", "Select this to see all the contributors of the engine!", function() {
			optionsTree.add(Type.createInstance(CreditsCodename, []));
		}));
		selectables.push(new TextOption("Friday Night Funkin'", "Select this to open the itch.io page of the original game to donate!", function() {
			CoolUtil.openURL("https://ninja-muffin24.itch.io/funkin");
		}));

		main = new OptionsScreen('Credits', 'The people who made this possible!', selectables);
		super.create();
	}
}