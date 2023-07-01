package funkin.editors;

import funkin.menus.MainMenuState;
import flixel.addons.display.FlxBackdrop;
import funkin.options.*;

class EditorTreeMenu extends TreeMenu {
	public var bg:FlxBackdrop;
	public var bgType:String = "default";

	public override function create() {
		super.create();

		FlxG.camera.fade(0xFF000000, 0.5, true);

		bg = new FlxBackdrop();
		bg.loadGraphic(Paths.image('editors/bgs/${bgType}'));
		bg.antialiasing = true;
		add(bg);
	}

	public override function exit() {
		FlxG.switchState(new MainMenuState());
	}

	public override function update(elapsed:Float) {
		super.update(elapsed);
		bg.x += elapsed * 125;
		bg.y += elapsed * 125;
	}
}