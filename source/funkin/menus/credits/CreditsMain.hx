package funkin.menus.credits;

import funkin.options.OptionsScreen;
import funkin.options.type.*;
import funkin.options.TreeMenu;
import haxe.xml.Access;

class CreditsMain extends TreeMenu {
	var bg:FlxSprite;

	public override function create() {
		bg = new FlxSprite(-80).loadGraphic(Paths.image('menus/menuBGBlue'));
		// bg.scrollFactor.set();
		bg.scale.set(1.15, 1.15);
		bg.updateHitbox();
		bg.screenCenter();
		bg.scrollFactor.set();
		bg.antialiasing = true;
		add(bg);

		var selectables:Array<OptionType> = [];
		for(source in [funkin.backend.assets.AssetsLibraryList.AssetSource.SOURCE, funkin.backend.assets.AssetsLibraryList.AssetSource.MODS]) {
			if (Paths.assetsTree.existsSpecific(Paths.xml('config/credits'), "TEXT", source)) {
				var access:Access = null;
				try {
					access = new Access(Xml.parse(Paths.assetsTree.getSpecificAsset(Paths.xml('config/credits'), "TEXT", source)));
				} catch(e) {
					Logs.trace('Error while parsing credits.xml: ${Std.string(e)}', ERROR);
				}
				
				if (access != null)
					for(c in parseCreditsFromXML(access, source))
						selectables.push(c);
			}
		}
		selectables.push(new TextOption("Codename Engine >", "Select this to see all the contributors of the engine!", function() {
			optionsTree.add(Type.createInstance(CreditsCodename, []));
		}));
		selectables.push(new TextOption("Friday Night Funkin'", "Select this to open the itch.io page of the original game to donate!", function() {
			CoolUtil.openURL("https://ninja-muffin24.itch.io/funkin");
		}));

		main = new OptionsScreen('Credits', 'The people who made this possible!', selectables);
		super.create();
	}

	/**
	 * XML STUFF
	 */
	public function parseCreditsFromXML(xml:Access, source:Bool):Array<OptionType> {
		var credsMenus:Array<OptionType> = [];

		for(node in xml.elements) {
			if (!node.has.name) {
				Logs.trace("A credit node requires a name attribute.", WARNING);
				continue;
			}
			var name = node.getAtt("name");
			var desc = node.getAtt("desc").getDefault("No Description");

			switch(node.name) {
				case "credit":
					credsMenus.push(new PortraitOption(name, desc, function() if(node.has.url) CoolUtil.openURL(node.att.url),
						node.has.icon && Paths.assetsTree.existsSpecific(Paths.image('credits/${node.att.icon}'), "IMAGE", source) ?
						FlxG.bitmap.add(Paths.image('credits/${node.att.icon}')) : null, node.has.size ? Std.parseInt(node.att.size) : 96
					));

				case "menu":
					credsMenus.push(new TextOption(name + " >", desc, function() {
						optionsTree.add(new OptionsScreen(name, desc, parseCreditsFromXML(node, source)));
					}));
			}
		}

		return credsMenus;
	}
}