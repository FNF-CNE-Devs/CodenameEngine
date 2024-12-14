package funkin.options;

import funkin.options.type.Checkbox;
import haxe.xml.Access;
import funkin.options.type.*;
import funkin.options.categories.*;
import funkin.options.TreeMenu;

class OptionsMenu extends TreeMenu {
	public static var mainOptions:Array<OptionCategory> = [
		{
			name: 'Controls',
			desc: 'Change Controls for Player 1 and Player 2!',
			state: null,
			substate: funkin.options.keybinds.KeybindsOptions
		},
		{
			name: 'Gameplay >',
			desc: 'Change Gameplay options such as Downscroll, Scroll Speed, Naughtyness...',
			state: GameplayOptions
		},
		{
			name: 'Appearance >',
			desc: 'Change Appearance options such as Flashing menus...',
			state: AppearanceOptions
		},
		{
			name: 'Miscellaneous >',
			desc: 'Use this menu to reset save data or engine settings.',
			state: MiscOptions
		}
	];

	public override function create() {
		super.create();

		CoolUtil.playMenuSong();

		DiscordUtil.call("onMenuLoaded", ["Options Menu"]);

		var bg:FlxSprite = new FlxSprite(-80).loadAnimatedGraphic(Paths.image('menus/menuBGBlue'));
		// bg.scrollFactor.set();
		bg.scale.set(1.15, 1.15);
		bg.updateHitbox();
		bg.screenCenter();
		bg.scrollFactor.set();
		bg.antialiasing = true;
		add(bg);

		main = new OptionsScreen("Options", "Select a category to continue.", [for(o in mainOptions) new TextOption(o.name, o.desc, function() {
			if (o.substate != null) {
				persistentUpdate = false;
				persistentDraw = true;
				if (o.substate is MusicBeatSubstate) {
					openSubState(o.substate);
				} else {
					openSubState(Type.createInstance(o.substate, []));
				}
			} else {
				if (o.state is OptionsScreen) {
					optionsTree.add(o.state);
				} else {
					optionsTree.add(Type.createInstance(o.state, []));
				}
			}
		})]);

		var overridedMods:Array<String> = [];

		for (i in funkin.backend.assets.ModsFolder.getLoadedMods()) {
			var xmlPath = Paths.xml('config/options/LIB_$i');

			if(overridedMods.contains(i))
				continue;

			if (Paths.assetsTree.existsSpecific(xmlPath, "TEXT")) {
				var access:Access = null;
				try {
					access = new Access(Xml.parse(Paths.assetsTree.getSpecificAsset(xmlPath, "TEXT")));
				} catch(e) {
					Logs.trace('Error while parsing options.xml: ${Std.string(e)}', ERROR);
				}
				if (access != null)
				{
					var firstElement = access.x.firstElement();
					if(firstElement.exists("override")) overridedMods.push(firstElement.get("override"));
					for(o in parseOptionsFromXML(access))
						main.add(o);
				}
			}
		}
	}

	public override function exit() {
		Options.save();
		Options.applySettings();
		super.exit();
	}

	/**
	 * XML STUFF
	 */
	public function parseOptionsFromXML(xml:Access):Array<OptionType> {
		var options:Array<OptionType> = [];

		for(node in xml.elements) {
			if (!node.has.name) {
				Logs.trace("An option node requires a name attribute.", WARNING);
				continue;
			}
			var name = node.getAtt("name");
			var desc = node.getAtt("desc").getDefault("No Description");

			switch(node.name) {
				case "checkbox":
					if (!node.has.id) {
						Logs.trace("A checkbox option requires an \"id\" for option saving.", WARNING);
						continue;
					}
					options.push(new Checkbox(name, desc, node.att.id, FlxG.save.data));

				case "number":
					if (!node.has.id) {
						Logs.trace("A number option requires an \"id\" for option saving.", WARNING);
						continue;
					}
					options.push(new NumOption(name, desc, Std.parseFloat(node.att.min), Std.parseFloat(node.att.max), Std.parseFloat(node.att.change), node.att.id, null, FlxG.save.data));
				case "choice":
					if (!node.has.id) {
						Logs.trace("A choice option requires an \"id\" for option saving.", WARNING);
						continue;
					}

					var optionOptions:Array<Dynamic> = [];
					var optionDisplayOptions:Array<String> = [];

					for(choice in node.elements) {
						optionOptions.push(choice.att.value);
						optionDisplayOptions.push(choice.att.name);
					}

					if(optionOptions.length > 0)
						options.push(new ArrayOption(name, desc, optionOptions, optionDisplayOptions, node.att.id, null, FlxG.save.data));

				case "menu":
					options.push(new TextOption(name + " >", desc, function() {
						optionsTree.add(new OptionsScreen(name, desc, parseOptionsFromXML(node)));
					}));
			}
		}

		return options;
	}
}