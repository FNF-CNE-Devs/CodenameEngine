package funkin.menus.credits;

import funkin.backend.system.github.GitHub;
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
		var xmlPath = Paths.xml('config/credits');
		for(source in [funkin.backend.assets.AssetsLibraryList.AssetSource.SOURCE, funkin.backend.assets.AssetsLibraryList.AssetSource.MODS]) {
			if (Paths.assetsTree.existsSpecific(xmlPath, "TEXT", source)) {
				var access:Access = null;
				try {
					access = new Access(Xml.parse(Paths.assetsTree.getSpecificAsset(xmlPath, "TEXT", source)));
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
			var desc = node.getAtt("desc").getDefault("No Description");

			if (node.name == "github") {
				if (!node.has.user) {
					Logs.trace("A github node requires a user attribute.", WARNING);
					continue;
				}

				var username = node.getAtt("user");
				var user = {  // Kind of forcing
					login: username,
					html_url: 'https://github.com/$username',
					avatar_url: 'https://github.com/$username.png'
				};

				credsMenus.push(new GithubIconOption(user, desc, null,
					node.has.customName ? node.att.customName : null, node.has.size ? Std.parseInt(node.att.size) : 96,
					node.has.portrait ? node.att.portrait.toLowerCase() == "false" ? false : true : true
				));
			} else {
				if (!node.has.name) {
					Logs.trace("A credit node requires a name attribute.", WARNING);
					continue;
				}
				var name = node.getAtt("name");

				switch(node.name) {
					case "credit":
						credsMenus.push(new PortraitOption(name, desc, function() if(node.has.url) CoolUtil.openURL(node.att.url),
							node.has.icon && Paths.assetsTree.existsSpecific(Paths.image('credits/${node.att.icon}'), "IMAGE", source) ?
							FlxG.bitmap.add(Paths.image('credits/${node.att.icon}')) : null, node.has.size ? Std.parseInt(node.att.size) : 96,
							node.has.portrait ? node.att.portrait.toLowerCase() == "false" ? false : true : true
						));

					case "menu":
						credsMenus.push(new TextOption(name + " >", desc, function() {
							optionsTree.add(new OptionsScreen(name, desc, parseCreditsFromXML(node, source)));
						}));
				}
			}
		}

		return credsMenus;
	}
}