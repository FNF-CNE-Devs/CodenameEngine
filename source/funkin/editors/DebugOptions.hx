package funkin.editors;

import funkin.options.type.*;
import funkin.options.OptionsScreen;
import funkin.options.TreeMenu;
import funkin.backend.utils.NativeAPI;

class DebugOptions extends TreeMenu {
	public override function create() {
		super.create();

		FlxG.camera.fade(0xFF000000, 0.5, true);

		var bg:FlxSprite = new FlxSprite(-80).loadAnimatedGraphic(Paths.image('menus/menuBGBlue'));
		// bg.scrollFactor.set();
		bg.scale.set(1.15, 1.15);
		bg.updateHitbox();
		bg.screenCenter();
		bg.scrollFactor.set();
		bg.antialiasing = true;
		add(bg);

		main = new DebugOptionsScreen();
	}
}

class DebugOptionsScreen extends OptionsScreen {
	public override function new() {
		super("Debug Options", "Use this menu to change debug options.");
		#if windows
		add(new TextOption(
			"Show Console",
			"Select this to show the debug console, which contains log information about the game.",
			function() {
				NativeAPI.allocConsole();
			}));
		#end
		add(new Checkbox(
			"Enable Editor SFXs",
			"If checked, will play sound effects when working on editors (ex: will play sfxs when checking checkboxes...)",
			"editorSFX"));
		add(new Checkbox(
			"Resizable Editors",
			"If checked, editors will be resizable and extensible like other programs instead of zooming in upon maximization.",
			"resizableEditors"));
		add(new Checkbox(
			"Intensive Blur",
			"If checked, will use more intensive blur that may be laggier but look better.",
			"intensiveBlur"));
	}
}