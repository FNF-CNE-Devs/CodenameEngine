package funkin.editors;

import funkin.editors.ui.*;

class UIDebugState extends UIState {
    public override function create() {
        super.create();
        var bg = new FlxSprite().makeGraphic(1, 1, 0xFF888888);
        bg.scale.set(FlxG.width, FlxG.height);
        bg.updateHitbox();
        bg.scrollFactor.set();
        add(bg);

        add(new UICheckbox(10, 10, "Test unchecked", false));
        add(new UICheckbox(10, 40, "Test checked", true));
    }
}