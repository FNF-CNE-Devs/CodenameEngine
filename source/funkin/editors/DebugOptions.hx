package funkin.editors;

import funkin.options.TreeMenu;

class DebugOptions extends TreeMenu {
    public override function create() {
        super.create();
        

        var bg:FlxSprite = new FlxSprite(-80).loadAnimatedGraphic(Paths.image('menus/menuBGBlue'));
        // bg.scrollFactor.set();
		bg.scale.set(1.15, 1.15);
		bg.updateHitbox();
		bg.screenCenter();
        bg.scrollFactor.set();
		bg.antialiasing = true;
		add(bg);

        main = new funkin.options.categories.DebugOptions();
    }
}